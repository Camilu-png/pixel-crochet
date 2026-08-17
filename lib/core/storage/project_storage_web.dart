import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/crochet_project.dart';

class PlatformStorage {
  static const _prefsKey = 'projects';

  static Future<List<CrochetProject>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(_prefsKey);
    if (encoded == null) return const [];

    final projects = <CrochetProject>[];
    final list = jsonDecode(encoded) as List<dynamic>;
    for (final item in list) {
      try {
        projects.add(CrochetProject.fromJson(item as Map<String, dynamic>));
      } catch (e) {
        // Skip corrupted entries
      }
    }

    projects.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return projects;
  }

  static Future<CrochetProject?> load(String id) async {
    final projects = await loadAll();
    for (final project in projects) {
      if (project.id == id) return project;
    }
    return null;
  }

  static Future<void> save(CrochetProject project) async {
    final projects = await loadAll();
    final index = projects.indexWhere((p) => p.id == project.id);
    if (index >= 0) {
      projects[index] = project;
    } else {
      projects.add(project);
    }
    await _writePrefs(projects);
  }

  static Future<void> delete(String id) async {
    final projects = await loadAll();
    projects.removeWhere((p) => p.id == id);
    await _writePrefs(projects);
  }

  static Future<void> _writePrefs(List<CrochetProject> projects) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      jsonEncode(projects.map((p) => p.toJson()).toList()),
    );
  }
}
