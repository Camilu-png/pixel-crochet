import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SyncBaseline {
  SyncBaseline({required this.revision, required Map<String, dynamic> project})
    : project = Map<String, dynamic>.from(project);

  final int revision;
  final Map<String, dynamic> project;
}

class ProjectSyncMetadataStore {
  static const _prefix = 'pixel_crochet_sync_v1';
  static const _ownersKey = 'pixel_crochet_sync_project_owners_v1';

  String _key(String userId) => '$_prefix:$userId';

  Future<Map<String, SyncBaseline>> loadBaselines(String userId) async {
    final raw = (await SharedPreferences.getInstance()).getString(_key(userId));
    if (raw == null) return {};
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return {};
    final baselines = decoded['baselines'];
    if (baselines is! Map) return {};

    return {
      for (final entry in baselines.entries)
        if (entry.key is String &&
            entry.value is Map &&
            (entry.value as Map)['revision'] is int &&
            (entry.value as Map)['project'] is Map)
          entry.key as String: SyncBaseline(
            revision: (entry.value as Map)['revision'] as int,
            project: Map<String, dynamic>.from(
              (entry.value as Map)['project'] as Map,
            ),
          ),
    };
  }

  Future<Set<String>> loadDeletedIds(String userId) async {
    final raw = (await SharedPreferences.getInstance()).getString(_key(userId));
    if (raw == null) return {};
    final decoded = jsonDecode(raw);
    if (decoded is! Map || decoded['deletedIds'] is! List) return {};
    return (decoded['deletedIds'] as List).whereType<String>().toSet();
  }

  Future<bool> isMigrationComplete(String userId) async =>
      (await _loadData(userId))['migrationComplete'] == true;

  Future<void> setMigrationComplete(String userId, bool complete) async {
    final data = await _loadData(userId);
    data['migrationComplete'] = complete;
    await _saveData(userId, data);
  }

  Future<Map<String, String>> loadProjectOwners() async {
    final raw = (await SharedPreferences.getInstance()).getString(_ownersKey);
    if (raw == null) return {};
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return {};
    return {
      for (final entry in decoded.entries)
        if (entry.key is String && entry.value is String)
          entry.key as String: entry.value as String,
    };
  }

  Future<void> setProjectOwner(String projectId, String userId) async {
    final owners = await loadProjectOwners()
      ..[projectId] = userId;
    await _saveOwners(owners);
  }

  Future<void> removeProjectOwner(String projectId) async {
    final owners = await loadProjectOwners()
      ..remove(projectId);
    await _saveOwners(owners);
  }

  Future<void> saveBaseline(
    String userId,
    String id,
    SyncBaseline baseline,
  ) async {
    final data = await _loadData(userId);
    final baselines = Map<String, dynamic>.from(data['baselines'] as Map);
    baselines[id] = {
      'revision': baseline.revision,
      'project': baseline.project,
    };
    data['baselines'] = baselines;
    await _saveData(userId, data);
  }

  Future<void> removeBaseline(String userId, String id) async {
    final data = await _loadData(userId);
    final baselines = Map<String, dynamic>.from(data['baselines'] as Map)
      ..remove(id);
    data['baselines'] = baselines;
    await _saveData(userId, data);
  }

  Future<void> markDeletedId(String userId, String id) async {
    final data = await _loadData(userId);
    final deletedIds = (data['deletedIds'] as List).whereType<String>().toSet()
      ..add(id);
    data['deletedIds'] = deletedIds.toList();
    await _saveData(userId, data);
  }

  Future<void> clearDeletedId(String userId, String id) async {
    final data = await _loadData(userId);
    final deletedIds = (data['deletedIds'] as List).whereType<String>().toSet()
      ..remove(id);
    data['deletedIds'] = deletedIds.toList();
    await _saveData(userId, data);
  }

  Future<Map<String, dynamic>> _loadData(String userId) async {
    final raw = (await SharedPreferences.getInstance()).getString(_key(userId));
    if (raw == null) {
      return {'baselines': <String, dynamic>{}, 'deletedIds': <String>[]};
    }
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      return {'baselines': <String, dynamic>{}, 'deletedIds': <String>[]};
    }
    return {
      'baselines': decoded['baselines'] is Map
          ? decoded['baselines']
          : <String, dynamic>{},
      'deletedIds': decoded['deletedIds'] is List
          ? decoded['deletedIds']
          : <String>[],
      'migrationComplete': decoded['migrationComplete'] == true,
    };
  }

  Future<void> _saveOwners(Map<String, String> owners) async {
    await (await SharedPreferences.getInstance()).setString(
      _ownersKey,
      jsonEncode(owners),
    );
  }

  Future<void> _saveData(String userId, Map<String, dynamic> data) async {
    await (await SharedPreferences.getInstance()).setString(
      _key(userId),
      jsonEncode(data),
    );
  }
}
