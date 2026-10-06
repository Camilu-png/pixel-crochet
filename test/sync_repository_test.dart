import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_crochet/core/models/color_block.dart';
import 'package:pixel_crochet/core/models/crochet_project.dart';
import 'package:pixel_crochet/core/models/pattern_row.dart';
import 'package:pixel_crochet/core/models/row_direction.dart';
import 'package:pixel_crochet/core/sync/project_sync_remote.dart';
import 'package:pixel_crochet/core/sync/project_sync_metadata_store.dart';
import 'package:pixel_crochet/core/sync/sync_repository.dart';
import 'package:pixel_crochet/core/sync/sync_state.dart';

void main() {
  group('SyncRepository', () {
    test('keeps guest data local without contacting Supabase', () async {
      final fixture = SyncFixture(userId: null)..addLocal(project('local'));

      final result = await fixture.repository.syncPending();

      expect(result, SyncState.localOnly);
      expect(fixture.remote.listCalls, 0);
      expect(fixture.local.keys, ['local']);
    });

    test('uploads local projects then records a confirmed baseline', () async {
      final projectToSync = project('new-project');
      final fixture = SyncFixture(userId: 'user-1')..addLocal(projectToSync);

      final result = await fixture.repository.syncPending();

      expect(result, SyncState.synced);
      expect(
        fixture.remote.projects['new-project']!.project,
        projectToSync.toJson(),
      );
      expect(fixture.metadata.baselines['user-1']!['new-project']!.revision, 1);
      expect(fixture.local['new-project']!.toJson(), projectToSync.toJson());
    });

    test('keeps a sync scoped to the account that started it', () async {
      final fixture = SyncFixture(userId: 'user-1')
        ..addLocal(project('account-project'));
      fixture.remote.onList = () => fixture.remote.userId = 'user-2';

      final result = await fixture.repository.syncPending();

      expect(result, SyncState.synced);
      expect(fixture.remote.requestedUserIds, ['user-1', 'user-1']);
      expect(fixture.remote.projects, contains('account-project'));
    });

    test('asks before uploading existing guest projects', () async {
      final fixture = SyncFixture(userId: 'user-1', completeMigration: false)
        ..addLocal(project('guest-project'));

      final result = await fixture.repository.syncPending();

      expect(result, SyncState.migrationRequired);
      expect(fixture.remote.projects, isEmpty);
      expect(fixture.local.keys, ['guest-project']);
      expect(await fixture.repository.pendingMigrationCount(), 1);
    });

    test('uploads guest projects only after migration is approved', () async {
      final fixture = SyncFixture(userId: 'user-1', completeMigration: false)
        ..addLocal(project('guest-project'));

      await fixture.repository.approveLocalMigration();
      final result = await fixture.repository.syncPending();

      expect(result, SyncState.synced);
      expect(fixture.remote.projects.keys, ['guest-project']);
      expect(fixture.metadata.owners['guest-project'], 'user-1');
    });

    test(
      'never uploads another account\'s locally backed-up projects',
      () async {
        final fixture = SyncFixture(userId: 'user-2')
          ..addLocal(project('user-1-project'))
          ..metadata.owners['user-1-project'] = 'user-1';

        final result = await fixture.repository.syncPending();

        expect(result, SyncState.synced);
        expect(fixture.remote.projects, isEmpty);
        expect(fixture.local.keys, ['user-1-project']);
      },
    );

    test('restores projects from the account on a new device', () async {
      final cloudProject = project('cloud-only');
      final fixture = SyncFixture(userId: 'user-1')
        ..remote.projects['cloud-only'] = RemoteProject(
          id: cloudProject.id,
          project: cloudProject.toJson(),
          revision: 4,
        );

      final result = await fixture.repository.syncPending();

      expect(result, SyncState.synced);
      expect(fixture.local['cloud-only']!.toJson(), cloudProject.toJson());
      expect(fixture.metadata.baselines['user-1']!['cloud-only']!.revision, 4);
    });

    test(
      'updates the cloud only when the saved revision still matches',
      () async {
        final base = project('shared');
        final localChanged = base.copyWith(name: 'Updated locally');
        final fixture = SyncFixture(userId: 'user-1')
          ..addLocal(localChanged)
          ..remote.projects['shared'] = RemoteProject(
            id: 'shared',
            project: base.toJson(),
            revision: 5,
          )
          ..metadata.baselines['user-1'] = {
            'shared': SyncBaseline(revision: 5, project: base.toJson()),
          };

        final result = await fixture.repository.syncPending();

        expect(result, SyncState.synced);
        expect(fixture.remote.projects['shared']!.revision, 6);
        expect(
          fixture.remote.projects['shared']!.project,
          localChanged.toJson(),
        );
      },
    );

    test(
      'syncs a local deletion only against its unchanged cloud revision',
      () async {
        final baseline = project('deleted');
        final fixture = SyncFixture(userId: 'user-1')
          ..remote.projects['deleted'] = RemoteProject(
            id: 'deleted',
            project: baseline.toJson(),
            revision: 3,
          )
          ..metadata.baselines['user-1'] = {
            'deleted': SyncBaseline(revision: 3, project: baseline.toJson()),
          }
          ..metadata.deletions['user-1'] = {'deleted'};

        final result = await fixture.repository.syncPending();

        expect(result, SyncState.synced);
        expect(fixture.remote.projects, isEmpty);
        expect(fixture.metadata.deletions['user-1'], isEmpty);
      },
    );

    test(
      'restores a cloud edit instead of applying a stale local deletion',
      () async {
        final baseline = project('deleted');
        final remoteChanged = baseline.copyWith(name: 'Changed elsewhere');
        final fixture = SyncFixture(userId: 'user-1')
          ..remote.projects['deleted'] = RemoteProject(
            id: 'deleted',
            project: remoteChanged.toJson(),
            revision: 4,
          )
          ..metadata.baselines['user-1'] = {
            'deleted': SyncBaseline(revision: 3, project: baseline.toJson()),
          }
          ..metadata.deletions['user-1'] = {'deleted'};

        final result = await fixture.repository.syncPending();

        expect(result, SyncState.conflict);
        expect(
          fixture.remote.projects['deleted']!.project,
          remoteChanged.toJson(),
        );
        expect(fixture.local['deleted']!.name, 'Changed elsewhere');
        expect(fixture.metadata.deletions['user-1'], isEmpty);
      },
    );

    test(
      'preserves both versions if local and cloud changed independently',
      () async {
        final base = project('shared');
        final localChanged = base.copyWith(name: 'Local progress');
        final remoteChanged = base.copyWith(name: 'Cloud progress');
        final fixture = SyncFixture(userId: 'user-1')
          ..addLocal(localChanged)
          ..remote.projects['shared'] = RemoteProject(
            id: 'shared',
            project: remoteChanged.toJson(),
            revision: 2,
          )
          ..metadata.baselines['user-1'] = {
            'shared': SyncBaseline(revision: 1, project: base.toJson()),
          };

        final result = await fixture.repository.syncPending();

        expect(result, SyncState.conflict);
        expect(
          fixture.remote.projects['shared']!.project,
          remoteChanged.toJson(),
        );
        expect(
          fixture.local.values.map((value) => value.name),
          contains('Cloud progress'),
        );
        expect(
          fixture.local.values.any(
            (value) => value.name.startsWith('Local progress'),
          ),
          isTrue,
        );
        expect(fixture.local.length, 2);
      },
    );

    test('network failure never changes the local library', () async {
      final original = project('offline');
      final fixture = SyncFixture(userId: 'user-1')
        ..addLocal(original)
        ..remote.failList = true;

      final result = await fixture.repository.syncPending();

      expect(result, SyncState.unavailable);
      expect(fixture.local['offline']!.toJson(), original.toJson());
    });

    test(
      'does not upload a project larger than the database row limit',
      () async {
        final tooLarge = project('large', name: 'x' * 270000);
        final fixture = SyncFixture(userId: 'user-1')..addLocal(tooLarge);

        final result = await fixture.repository.syncPending();

        expect(result, SyncState.unavailable);
        expect(fixture.remote.projects, isEmpty);
        expect(fixture.local['large']!.name, tooLarge.name);
      },
    );
  });
}

class SyncFixture {
  SyncFixture({required String? userId, bool completeMigration = true}) {
    remote = FakeProjectSyncRemote(userId: userId);
    if (completeMigration && userId != null) {
      metadata.completedMigrations.add(userId);
    }
    repository = SyncRepository(
      remote: remote,
      metadata: metadata,
      loadLocalProjects: () async => local.values.toList(),
      saveLocalProject: (value) async {
        local[value.id] = value;
      },
      onStateChanged: (state) {},
    );
  }

  late final FakeProjectSyncRemote remote;
  late final SyncRepository repository;
  final Map<String, CrochetProject> local = {};
  final FakeProjectSyncMetadataStore metadata = FakeProjectSyncMetadataStore();

  void addLocal(CrochetProject value) => local[value.id] = value;
}

class FakeProjectSyncRemote implements ProjectSyncRemote {
  FakeProjectSyncRemote({required this.userId});

  @override
  String? userId;
  final Map<String, RemoteProject> projects = {};
  final List<String> requestedUserIds = [];
  int listCalls = 0;
  bool failList = false;
  void Function()? onList;

  @override
  Future<List<RemoteProject>> listProjects({required String userId}) async {
    requestedUserIds.add(userId);
    listCalls++;
    if (failList) throw StateError('offline');
    onList?.call();
    return projects.values.toList();
  }

  @override
  Future<RemoteProject?> insertProject({
    required String userId,
    required Map<String, dynamic> project,
  }) async {
    requestedUserIds.add(userId);
    final id = project['id'] as String;
    if (projects.containsKey(id)) return null;
    final inserted = RemoteProject(id: id, project: project, revision: 1);
    projects[id] = inserted;
    return inserted;
  }

  @override
  Future<RemoteProject?> updateProject({
    required String userId,
    required String id,
    required int expectedRevision,
    required Map<String, dynamic> project,
  }) async {
    requestedUserIds.add(userId);
    final current = projects[id];
    if (current == null || current.revision != expectedRevision) return null;
    final updated = RemoteProject(
      id: id,
      project: project,
      revision: expectedRevision + 1,
    );
    projects[id] = updated;
    return updated;
  }

  @override
  Future<bool> deleteProject({
    required String userId,
    required String id,
    required int expectedRevision,
  }) async {
    final current = projects[id];
    if (current == null || current.revision != expectedRevision) return false;
    projects.remove(id);
    return true;
  }
}

class FakeProjectSyncMetadataStore implements ProjectSyncMetadataStore {
  final Map<String, Map<String, SyncBaseline>> baselines = {};
  final Map<String, Set<String>> deletions = {};
  final Set<String> completedMigrations = {};
  final Map<String, String> owners = {};

  @override
  Future<Map<String, SyncBaseline>> loadBaselines(String userId) async =>
      baselines[userId] ?? {};

  @override
  Future<Set<String>> loadDeletedIds(String userId) async =>
      deletions[userId] ?? {};

  @override
  Future<void> saveBaseline(
    String userId,
    String id,
    SyncBaseline baseline,
  ) async => (baselines[userId] ??= {})[id] = baseline;

  @override
  Future<void> removeBaseline(String userId, String id) async =>
      baselines[userId]?.remove(id);

  @override
  Future<void> clearDeletedId(String userId, String id) async =>
      deletions[userId]?.remove(id);

  @override
  Future<void> markDeletedId(String userId, String id) async {
    (deletions[userId] ??= {}).add(id);
  }

  @override
  Future<bool> isMigrationComplete(String userId) async =>
      completedMigrations.contains(userId);

  @override
  Future<void> setMigrationComplete(String userId, bool complete) async {
    if (complete) {
      completedMigrations.add(userId);
    } else {
      completedMigrations.remove(userId);
    }
  }

  @override
  Future<Map<String, String>> loadProjectOwners() async => Map.of(owners);

  @override
  Future<void> setProjectOwner(String projectId, String userId) async {
    owners[projectId] = userId;
  }

  @override
  Future<void> removeProjectOwner(String projectId) async {
    owners.remove(projectId);
  }
}

CrochetProject project(String id, {String? name}) => CrochetProject(
  id: id,
  name: name ?? 'Project $id',
  width: 2,
  height: 1,
  rows: [
    PatternRow(
      rowNumber: 1,
      direction: RowDirection.readRightToLeft,
      colorBlocks: [ColorBlock(colorName: 'red', count: 2)],
    ),
  ],
);
