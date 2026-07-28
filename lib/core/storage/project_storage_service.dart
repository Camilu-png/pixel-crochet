import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../models/crochet_project.dart';

final storageServiceProvider = Provider<ProjectStorageService>((ref) {
  return const ProjectStorageService();
});

class ProjectStorageService {
  const ProjectStorageService();

  Future<Directory> get _projectsDir async {
    final appDir = await getApplicationDocumentsDirectory();
    final projectsDir = Directory('${appDir.path}/projects');
    if (!await projectsDir.exists()) {
      await projectsDir.create(recursive: true);
    }
    return projectsDir;
  }

  Future<List<CrochetProject>> loadAll() async {
    final dir = await _projectsDir;
    final files = await dir.list().where((f) => f.path.endsWith('.json')).toList();
    
    final projects = <CrochetProject>[];
    for (final file in files) {
      try {
        final content = await File(file.path).readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;
        projects.add(CrochetProject.fromJson(json));
      } catch (_) {
        // Skip corrupted files
      }
    }
    
    projects.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return projects;
  }

  Future<CrochetProject?> load(String id) async {
    final dir = await _projectsDir;
    final file = File('${dir.path}/$id.json');
    
    if (!await file.exists()) return null;
    
    final content = await file.readAsString();
    final json = jsonDecode(content) as Map<String, dynamic>;
    return CrochetProject.fromJson(json);
  }

  Future<void> save(CrochetProject project) async {
    final dir = await _projectsDir;
    final file = File('${dir.path}/${project.id}.json');
    await file.writeAsString(jsonEncode(project.toJson()));
  }

  Future<void> delete(String id) async {
    final dir = await _projectsDir;
    final file = File('${dir.path}/$id.json');
    if (await file.exists()) {
      await file.delete();
    }
  }
}
