import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/crochet_project.dart';
import '../../../core/storage/project_storage_service.dart';

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
  }

  Future<void> updateProject(CrochetProject project) async {
    await _storage.save(project);
    ref.invalidateSelf();
  }

  Future<void> deleteProject(String id) async {
    await _storage.delete(id);
    ref.invalidateSelf();
  }
}
