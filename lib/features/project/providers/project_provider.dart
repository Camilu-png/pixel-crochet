import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/crochet_project.dart';
import '../../../core/storage/project_storage_service.dart';
import '../../home/providers/home_provider.dart';

final projectProvider = AsyncNotifierProvider.autoDispose
    .family<ProjectNotifier, CrochetProject, String>(ProjectNotifier.new);

class ProjectNotFoundException implements Exception {
  const ProjectNotFoundException();
}

class ProjectNotifier
    extends AutoDisposeFamilyAsyncNotifier<CrochetProject, String> {
  ProjectStorageService get _storage => ref.read(storageServiceProvider);

  @override
  Future<CrochetProject> build(String projectId) async {
    final project = await _storage.load(projectId);
    if (project == null) {
      throw const ProjectNotFoundException();
    }
    return project;
  }

  Future<void> setCurrentRow(int index) async {
    final project = state.valueOrNull;
    if (project == null || project.rows.isEmpty) return;

    final clamped = index.clamp(0, project.rows.length - 1);
    await _persist(project.copyWith(currentRowIndex: clamped));
  }

  Future<void> toggleBlock(int blockIndex) async {
    final project = state.valueOrNull;
    if (project == null) return;

    final updated = project.toggleBlock(project.currentRowIndex, blockIndex);
    await _persist(updated);
  }

  Future<void> updateProject(CrochetProject update) async {
    await _persist(update);
  }

  Future<void> delete() async {
    final project = state.valueOrNull;
    if (project != null) {
      await _storage.delete(project.id);
    }
    ref.invalidate(projectsProvider);
  }

  Future<void> _persist(CrochetProject updated) async {
    state = AsyncData(updated);
    await _storage.save(updated);
    ref.invalidate(projectsProvider);
  }
}
