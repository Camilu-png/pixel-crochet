import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/crochet_project.dart';

class PlatformStorage {
  static Future<List<CrochetProject>> loadAll() async {
    final dir = await _projectsDir();
    final files = await dir
        .list()
        .where((f) => f.path.endsWith('.json'))
        .toList();

    final projects = <CrochetProject>[];
    for (final file in files) {
      try {
        final content = await File(file.path).readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;
        projects.add(CrochetProject.fromJson(json));
      } catch (e) {
        // Skip corrupted files
      }
    }

    projects.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return projects;
  }

  static Future<CrochetProject?> load(String id) async {
    final dir = await _projectsDir();
    final file = File('${dir.path}/$id.json');
    if (!await file.exists()) return null;
    final content = await file.readAsString();
    final json = jsonDecode(content) as Map<String, dynamic>;
    return CrochetProject.fromJson(json);
  }

  static Future<void> save(CrochetProject project) async {
    final dir = await _projectsDir();
    final file = File('${dir.path}/${project.id}.json');
    await file.writeAsString(jsonEncode(project.toJson()));
  }

  static Future<void> delete(String id) async {
    final dir = await _projectsDir();
    final file = File('${dir.path}/$id.json');
    if (await file.exists()) await file.delete();
  }

  static Future<Directory> _projectsDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/projects');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }
}
