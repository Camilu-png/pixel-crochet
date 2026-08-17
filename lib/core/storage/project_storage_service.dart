import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/crochet_project.dart';
import 'project_storage_stub.dart'
    if (dart.library.io) 'project_storage_io.dart'
    if (dart.library.js_interop) 'project_storage_web.dart';

final storageServiceProvider = Provider<ProjectStorageService>((ref) {
  return ProjectStorageService();
});

class ProjectStorageService {
  static const _prefsKey = 'projects';

  bool get _isWeb => kIsWeb;

  Future<List<CrochetProject>> loadAll() async {
    if (_isWeb) {
      return _loadAllFromPrefs();
    }
    return PlatformStorage.loadAll();
  }

  Future<CrochetProject?> load(String id) async {
    if (_isWeb) {
      return _loadFromPrefs(id);
    }
    return PlatformStorage.load(id);
  }

  Future<void> save(CrochetProject project) async {
    if (_isWeb) {
      await _saveToPrefs(project);
      return;
    }
    await PlatformStorage.save(project);
  }

  Future<void> delete(String id) async {
    if (_isWeb) {
      await _deleteFromPrefs(id);
      return;
    }
    await PlatformStorage.delete(id);
  }

  // Web helpers (SharedPreferences)
  Future<List<CrochetProject>> _loadAllFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(_prefsKey);
    if (encoded == null) return const [];

    final projects = <CrochetProject>[];
    final list = jsonDecode(encoded) as List<dynamic>;
    for (final item in list) {
      try {
        projects.add(CrochetProject.fromJson(item as Map<String, dynamic>));
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
