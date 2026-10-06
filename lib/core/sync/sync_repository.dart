import 'dart:async';
import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../models/crochet_project.dart';
import 'project_sync_metadata_store.dart';
import 'project_sync_remote.dart';
import 'sync_state.dart';

typedef LoadLocalProjects = Future<List<CrochetProject>> Function();
typedef SaveLocalProject = Future<void> Function(CrochetProject project);
typedef SyncStateChanged = void Function(SyncState state);

class SyncRepository {
  SyncRepository({
    required ProjectSyncRemote remote,
    required ProjectSyncMetadataStore metadata,
    required LoadLocalProjects loadLocalProjects,
    required SaveLocalProject saveLocalProject,
    required SyncStateChanged onStateChanged,
  }) : _remote = remote,
       _metadata = metadata,
       _loadLocalProjects = loadLocalProjects,
       _saveLocalProject = saveLocalProject,
       _onStateChanged = onStateChanged;

  static const _maxProjectBytes = 262144;
  static const _uuid = Uuid();

  final ProjectSyncRemote _remote;
  final ProjectSyncMetadataStore _metadata;
  final LoadLocalProjects _loadLocalProjects;
  final SaveLocalProject _saveLocalProject;
  final SyncStateChanged _onStateChanged;

  Future<SyncState>? _running;
  bool _rerunRequested = false;

  Future<SyncState> syncPending() {
    if (_remote.userId == null) {
      _onStateChanged(SyncState.localOnly);
      return Future.value(SyncState.localOnly);
    }
    _rerunRequested = true;
    return _running ??= _drain().whenComplete(() => _running = null);
  }

  Future<void> markLocalDeletion(String id) async {
    final userId = _remote.userId;
    if (userId == null) return;
    final owner = (await _metadata.loadProjectOwners())[id];
    if (owner == null || owner == userId) {
      await _metadata.markDeletedId(userId, id);
    }
  }

  Future<void> cancelLocalDeletion(String id) async {
    final userId = _remote.userId;
    if (userId != null) await _metadata.clearDeletedId(userId, id);
  }

  Future<int> pendingMigrationCount() async {
    final userId = _remote.userId;
    if (userId == null) return 0;
    final owners = await _metadata.loadProjectOwners();
    final projects = await _loadLocalProjects();
    return projects.where((project) => owners[project.id] == null).length;
  }

  Future<void> approveLocalMigration() async {
    final userId = _remote.userId;
    if (userId == null) throw StateError('Sign in before migrating projects.');
    await _metadata.setMigrationComplete(userId, true);
  }

  Future<SyncState> _drain() async {
    var result = SyncState.pending;
    do {
      _rerunRequested = false;
      result = await _syncOnce();
    } while (_rerunRequested && result != SyncState.unavailable);
    _onStateChanged(result);
    return result;
  }

  Future<SyncState> _syncOnce() async {
    final userId = _remote.userId;
    if (userId == null) return SyncState.localOnly;
    _onStateChanged(SyncState.pending);

    try {
      final baselines = await _metadata.loadBaselines(userId);
      final deletedIds = Set<String>.from(
        await _metadata.loadDeletedIds(userId),
      );
      final localOwners = await _metadata.loadProjectOwners();
      final allLocalProjects = await _loadLocalProjects();
      final userLocalProjects = allLocalProjects.where((project) {
        final owner = localOwners[project.id];
        return owner == null || owner == userId;
      }).toList();
      if (!await _metadata.isMigrationComplete(userId)) {
        final hasGuestProjects = userLocalProjects.any(
          (project) => localOwners[project.id] == null,
        );
        if (hasGuestProjects) return SyncState.migrationRequired;
        await _metadata.setMigrationComplete(userId, true);
      }

      final remoteProjects = {
        for (final project in await _remote.listProjects(userId: userId))
          project.id: project,
      };
      var conflicted = await _applyPendingDeletes(
        userId,
        deletedIds,
        baselines,
        remoteProjects,
      );

      final localProjects = {
        for (final project in await _loadLocalProjects())
          if (localOwners[project.id] == null ||
              localOwners[project.id] == userId)
            project.id: project,
      };
      final allIds = <String>{...localProjects.keys, ...remoteProjects.keys};

      for (final id in allIds) {
        if (deletedIds.contains(id)) continue;
        final local = localProjects[id];
        final remote = remoteProjects[id];
        final baseline = baselines[id];

        if (local == null && remote == null) continue;
        if (local == null && remote != null) {
          for (final foreignProject in allLocalProjects.where(
            (project) =>
                project.id == id &&
                localOwners[project.id] != null &&
                localOwners[project.id] != userId,
          )) {
            final preserved = _copyWithNewId(
              foreignProject,
              suffix: ' (otra cuenta)',
            );
            await _saveLocalProject(preserved);
            await _metadata.setProjectOwner(
              preserved.id,
              localOwners[foreignProject.id]!,
            );
            conflicted = true;
          }
          final restored = _parseRemote(remote);
          await _saveLocalProject(restored);
          await _saveBaseline(userId, baselines, id, remote);
          continue;
        }
        if (local != null && remote == null) {
          final inserted = await _insert(userId, local);
          if (inserted == null) {
            conflicted = true;
            continue;
          }
          await _saveBaseline(userId, baselines, id, inserted);
          continue;
        }

        final localProject = local!;
        final remoteProject = remote!;
        if (baseline == null) {
          if (_sameProject(localProject.toJson(), remoteProject.project)) {
            await _saveBaseline(userId, baselines, id, remoteProject);
          } else {
            await _preserveConflict(
              userId,
              localProject,
              remoteProject,
              baselines,
            );
            conflicted = true;
          }
          continue;
        }

        final localChanged = !_sameProject(
          localProject.toJson(),
          baseline.project,
        );
        final remoteChanged =
            remoteProject.revision != baseline.revision ||
            !_sameProject(remoteProject.project, baseline.project);

        if (!localChanged && !remoteChanged) continue;
        if (!localChanged) {
          await _saveLocalProject(_parseRemote(remoteProject));
          await _saveBaseline(userId, baselines, id, remoteProject);
          continue;
        }
        if (!remoteChanged) {
          final updated = await _update(
            userId,
            localProject,
            baseline.revision,
          );
          if (updated == null) {
            conflicted = true;
            continue;
          }
          await _saveBaseline(userId, baselines, id, updated);
          continue;
        }
        if (_sameProject(localProject.toJson(), remoteProject.project)) {
          await _saveBaseline(userId, baselines, id, remoteProject);
          continue;
        }

        await _preserveConflict(userId, localProject, remoteProject, baselines);
        conflicted = true;
      }

      return conflicted ? SyncState.conflict : SyncState.synced;
    } catch (_) {
      return SyncState.unavailable;
    }
  }

  Future<bool> _applyPendingDeletes(
    String userId,
    Set<String> deletedIds,
    Map<String, SyncBaseline> baselines,
    Map<String, RemoteProject> remoteProjects,
  ) async {
    var conflicted = false;
    for (final id in deletedIds) {
      final remote = remoteProjects[id];
      final baseline = baselines[id];
      if (remote == null) {
        await _metadata.removeBaseline(userId, id);
        await _metadata.clearDeletedId(userId, id);
        await _metadata.removeProjectOwner(id);
        baselines.remove(id);
        continue;
      }

      if (baseline != null &&
          remote.revision == baseline.revision &&
          _sameProject(remote.project, baseline.project)) {
        if (await _remote.deleteProject(
          userId: userId,
          id: id,
          expectedRevision: baseline.revision,
        )) {
          remoteProjects.remove(id);
          baselines.remove(id);
          await _metadata.removeBaseline(userId, id);
          await _metadata.clearDeletedId(userId, id);
          await _metadata.removeProjectOwner(id);
        } else {
          conflicted = true;
        }
        continue;
      }

      await _saveLocalProject(_parseRemote(remote));
      await _saveBaseline(userId, baselines, id, remote);
      await _metadata.clearDeletedId(userId, id);
      conflicted = true;
    }
    return conflicted;
  }

  Future<RemoteProject?> _insert(String userId, CrochetProject project) async {
    _validateSize(project);
    return _remote.insertProject(userId: userId, project: project.toJson());
  }

  Future<RemoteProject?> _update(
    String userId,
    CrochetProject project,
    int revision,
  ) async {
    _validateSize(project);
    return _remote.updateProject(
      userId: userId,
      id: project.id,
      expectedRevision: revision,
      project: project.toJson(),
    );
  }

  void _validateSize(CrochetProject project) {
    final bytes = utf8.encode(jsonEncode(project.toJson())).length;
    if (bytes > _maxProjectBytes) {
      throw StateError('Project exceeds the 256 KiB cloud limit.');
    }
  }

  Future<void> _preserveConflict(
    String userId,
    CrochetProject local,
    RemoteProject remote,
    Map<String, SyncBaseline> baselines,
  ) async {
    final remoteVersion = _parseRemote(remote);
    final localCopy = _copyWithNewId(local, suffix: ' (copia local)');
    await _saveLocalProject(remoteVersion);
    await _saveLocalProject(localCopy);
    await _saveBaseline(userId, baselines, remote.id, remote);

    final uploadedCopy = await _insert(userId, localCopy);
    if (uploadedCopy != null) {
      await _saveBaseline(userId, baselines, localCopy.id, uploadedCopy);
    }
  }

  Future<void> _saveBaseline(
    String userId,
    Map<String, SyncBaseline> baselines,
    String id,
    RemoteProject remote,
  ) async {
    final baseline = _baseline(remote);
    baselines[id] = baseline;
    await _metadata.saveBaseline(userId, id, baseline);
    await _metadata.setProjectOwner(id, userId);
  }

  SyncBaseline _baseline(RemoteProject remote) =>
      SyncBaseline(revision: remote.revision, project: remote.project);

  CrochetProject _copyWithNewId(
    CrochetProject project, {
    required String suffix,
  }) {
    final json = project.toJson()
      ..['id'] = _uuid.v4()
      ..['name'] = '${project.name}$suffix';
    return CrochetProject.fromJson(json);
  }

  CrochetProject _parseRemote(RemoteProject remote) {
    final project = CrochetProject.fromJson(remote.project);
    if (project.id != remote.id) {
      throw const FormatException('Cloud project ID does not match its row.');
    }
    return project;
  }

  bool _sameProject(Map<String, dynamic> left, Map<String, dynamic> right) =>
      jsonEncode(_sortJson(left)) == jsonEncode(_sortJson(right));

  Object? _sortJson(Object? value) {
    if (value is Map) {
      final keys = value.keys.map((key) => key.toString()).toList()..sort();
      return {for (final key in keys) key: _sortJson(value[key])};
    }
    if (value is List) return value.map(_sortJson).toList();
    return value;
  }
}
