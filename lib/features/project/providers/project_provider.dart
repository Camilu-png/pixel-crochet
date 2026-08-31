import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/crochet_project.dart';
import '../../../core/storage/project_storage_service.dart';
import '../../home/providers/home_provider.dart';

final projectProvider = AsyncNotifierProvider.autoDispose
    .family<ProjectNotifier, CrochetProject, String>(ProjectNotifier.new);

/// Holds the last failed-save error for a project (null when none). Cleared on
/// the next successful save. Lets the UI surface transient persistence
/// failures (e.g. quota exceeded) without crashing.
final projectSaveErrorProvider =
    StateProvider.autoDispose.family<Object?, String>((ref, id) => null);

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

  /// Persists [updated], optimistically reflecting the change but rolling back
  /// to the previous value if the write fails so unsaved work is never shown
  /// as saved. Failures are exposed through [projectSaveErrorProvider] so
  /// fire-and-forget callers cannot crash the app.
  Future<void> _persist(CrochetProject updated) async {
    final projectId = arg;
    final previous = state.valueOrNull;
    final saveError = ref.read(projectSaveErrorProvider(projectId).notifier);
    state = AsyncData(updated);
    try {
      await _storage.save(updated);
      saveError.state = null;
      ref.invalidate(projectsProvider);
    } catch (e, st) {
      saveError.state = e;
      state = previous != null ? AsyncData(previous) : AsyncError(e, st);
    }
  }
}
