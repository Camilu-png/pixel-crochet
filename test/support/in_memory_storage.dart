import 'package:pixel_crochet/core/models/crochet_project.dart';
import 'package:pixel_crochet/core/storage/project_storage_service.dart';

/// [ProjectStorageService] backed by an in-memory map, so tests can assert on
/// the projects that were actually written.
class InMemoryStorage extends ProjectStorageService {
  InMemoryStorage(this.projects);

  final Map<String, CrochetProject> projects;

  @override
  Future<CrochetProject?> load(String id) async => projects[id];

  @override
  Future<void> save(CrochetProject project) async {
    projects[project.id] = project;
  }
}
