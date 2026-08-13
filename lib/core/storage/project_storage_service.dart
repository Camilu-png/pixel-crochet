import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/crochet_project.dart';

final storageServiceProvider = Provider<ProjectStorageService>((ref) {
  return ProjectStorageService();
});

class ProjectStorageService {
  /// [baseDirectory] overrides the app documents directory. Used by tests to
  /// run against an isolated temporary directory.
  ProjectStorageService({Directory? baseDirectory}) : _baseDirectory = baseDirectory;

  final Directory? _baseDirectory;

  static const _prefsKey = 'projects';

  /// On web there is no filesystem, so projects live in localStorage.
  bool get _isWeb => kIsWeb;

  Future<List<CrochetProject>> loadAll() async {
    if (_isWeb) {
      return _loadAllFromPrefs();
    }

    final dir = await _projectsDir;
    final files = await dir.list().where((f) => f.path.endsWith('.json')).toList();

    final projects = <CrochetProject>[];
    for (final file in files) {
      try {
        final content = await File(file.path).readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;
        projects.add(CrochetProject.fromJson(json));
      } catch (e) {
        debugPrint('Skipping corrupted project file: ${file.path} ($e)');
      }
    }

    projects.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return projects;
  }

  Future<CrochetProject?> load(String id) async {
    if (_isWeb) {
      return _loadFromPrefs(id);
    }

    final dir = await _projectsDir;
    final file = File('${dir.path}/$id.json');

    if (!await file.exists()) return null;

    final content = await file.readAsString();
    final json = jsonDecode(content) as Map<String, dynamic>;
    return CrochetProject.fromJson(json);
  }

  Future<void> save(CrochetProject project) async {
    if (_isWeb) {
      await _saveToPrefs(project);
      return;
    }

    final dir = await _projectsDir;
    final file = File('${dir.path}/${project.id}.json');
    await file.writeAsString(jsonEncode(project.toJson()));
  }

  Future<void> delete(String id) async {
    if (_isWeb) {
      await _deleteFromPrefs(id);
      return;
    }

    final dir = await _projectsDir;
    final file = File('${dir.path}/$id.json');
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<Directory> get _projectsDir async {
    final appDir = _baseDirectory ?? await getApplicationDocumentsDirectory();
    final projectsDir = Directory('${appDir.path}/projects');
    if (!await projectsDir.exists()) {
      await projectsDir.create(recursive: true);
    }
    return projectsDir;
  }

  Future<List<CrochetProject>> _loadAllFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(_prefsKey);
    if (encoded == null) return const [];

    final projects = <CrochetProject>[];
    final list = jsonDecode(encoded) as List<dynamic>;
    for (final item in list) {
      try {
        projects.add(
          CrochetProject.fromJson(item as Map<String, dynamic>),
        );
      } catch (e) {
        debugPrint('Skipping corrupted project entry ($e)');
      }
    }

    projects.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return projects;
  }

  Future<CrochetProject?> _loadFromPrefs(String id) async {
    final projects = await _loadAllFromPrefs();
    for (final project in projects) {
      if (project.id == id) return project;
    }
    return null;
  }

  Future<void> _saveToPrefs(CrochetProject project) async {
    final projects = await _loadAllFromPrefs();
    final index = projects.indexWhere((p) => p.id == project.id);
    if (index >= 0) {
      projects[index] = project;
    } else {
      projects.add(project);
    }
    await _writePrefs(projects);
  }

  Future<void> _deleteFromPrefs(String id) async {
    final projects = await _loadAllFromPrefs();
    projects.removeWhere((p) => p.id == id);
    await _writePrefs(projects);
  }

  Future<void> _writePrefs(List<CrochetProject> projects) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      jsonEncode(projects.map((p) => p.toJson()).toList()),
    );
  }
}
