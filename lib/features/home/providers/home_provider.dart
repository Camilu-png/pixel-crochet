import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/crochet_project.dart';
import '../../../core/storage/project_storage_service.dart';
import '../../../core/sync/sync_providers.dart';

final projectsProvider =
    AsyncNotifierProvider<ProjectsNotifier, List<CrochetProject>>(
      ProjectsNotifier.new,
    );

class ProjectsNotifier extends AsyncNotifier<List<CrochetProject>> {
  ProjectStorageService get _storage => ref.read(storageServiceProvider);

  @override
  Future<List<CrochetProject>> build() async {
    return _storage.loadAll();
  }

  Future<void> addProject(CrochetProject project) async {
    await _storage.save(project);
    ref.invalidateSelf();
    _syncInBackground();
  }

  Future<void> updateProject(CrochetProject project) async {
    await _storage.save(project);
    ref.invalidateSelf();
    _syncInBackground();
  }

  Future<void> deleteProject(String id) async {
    final syncRepository = ref.read(syncRepositoryProvider);
    await syncRepository?.markLocalDeletion(id);
    try {
      await _storage.delete(id);
    } catch (_) {
      await syncRepository?.cancelLocalDeletion(id);
      rethrow;
    }
    ref.invalidateSelf();
    _syncInBackground();
  }

  void _syncInBackground() {
    final syncRepository = ref.read(syncRepositoryProvider);
    if (syncRepository != null) unawaited(syncRepository.syncPending());
  }
}
