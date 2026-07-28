import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/crochet_project.dart';
import '../../../core/storage/project_storage_service.dart';

const _storageService = ProjectStorageService();

final projectsProvider =
    AsyncNotifierProvider<ProjectsNotifier, List<CrochetProject>>(
  ProjectsNotifier.new,
);

class ProjectsNotifier extends AsyncNotifier<List<CrochetProject>> {
  @override
  Future<List<CrochetProject>> build() async {
    return _storageService.loadAll();
  }

  Future<void> addProject(CrochetProject project) async {
    await _storageService.save(project);
    ref.invalidateSelf();
  }

  Future<void> deleteProject(String id) async {
    await _storageService.delete(id);
    ref.invalidateSelf();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}
