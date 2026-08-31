import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
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
        debugPrint('Skipping corrupted project file ${file.path}: $e');
        await _restoreBackup(file.path);
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
    final path = '${dir.path}/${project.id}.json';
    final tmpPath = '$path.tmp';

    // Write to a temp file first, then atomically rename into place. This
    // guarantees an interrupted/failed write never leaves a truncated JSON.
    await File(tmpPath).writeAsString(jsonEncode(project.toJson()));

    final target = File(path);
    if (await target.exists()) {
      await File('$path.bak')
          .writeAsString(await target.readAsString(), flush: true);
    }
    await File(tmpPath).rename(path);
  }

  static Future<void> _restoreBackup(String path) async {
    final backup = File('$path.bak');
    if (!await backup.exists()) return;
    try {
      final content = await backup.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      // Only restore if the backup itself is valid, otherwise leave the
      // original file untouched so the user can recover it manually.
      CrochetProject.fromJson(json);
      await backup.rename(path);
      debugPrint('Restored project from backup for $path');
    } catch (e) {
      debugPrint('Backup for $path is also corrupted ($e)');
    }
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
