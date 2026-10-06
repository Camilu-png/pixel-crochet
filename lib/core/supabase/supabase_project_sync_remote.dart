import 'package:supabase_flutter/supabase_flutter.dart';

import '../sync/project_sync_remote.dart';

class SupabaseProjectSyncRemote implements ProjectSyncRemote {
  SupabaseProjectSyncRemote(this._client);

  final SupabaseClient _client;

  static const _table = 'user_projects';
  static const _columns = 'id, project, revision';

  @override
  String? get userId => _client.auth.currentUser?.id;

  @override
  Future<List<RemoteProject>> listProjects({required String userId}) async {
    _requireUser(userId);
    final rows = await _client
        .from(_table)
        .select(_columns)
        .eq('user_id', userId);
    return (rows as List<dynamic>)
        .map((row) => _decodeRow(Map<String, dynamic>.from(row as Map)))
        .toList();
  }

  @override
  Future<RemoteProject?> insertProject({
    required String userId,
    required Map<String, dynamic> project,
  }) async {
    _requireUser(userId);
    final row = await _client
        .from(_table)
        .insert({
          'user_id': userId,
          'id': project['id'],
          'project': project,
          'revision': 1,
        })
        .select(_columns)
        .maybeSingle();
    return row == null ? null : _decodeRow(row);
  }

  @override
  Future<RemoteProject?> updateProject({
    required String userId,
    required String id,
    required int expectedRevision,
    required Map<String, dynamic> project,
  }) async {
    _requireUser(userId);
    final row = await _client
        .from(_table)
        .update({
          'project': project,
          'revision': expectedRevision + 1,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('user_id', userId)
        .eq('id', id)
        .eq('revision', expectedRevision)
        .select(_columns)
        .maybeSingle();
    return row == null ? null : _decodeRow(row);
  }

  @override
  Future<bool> deleteProject({
    required String userId,
    required String id,
    required int expectedRevision,
  }) async {
    _requireUser(userId);
    final row = await _client
        .from(_table)
        .delete()
        .eq('user_id', userId)
        .eq('id', id)
        .eq('revision', expectedRevision)
        .select('id')
        .maybeSingle();
    return row != null;
  }

  void _requireUser(String expectedUserId) {
    final currentUserId = userId;
    if (currentUserId == null) {
      throw const AuthException('Sign in to sync projects.');
    }
    if (currentUserId != expectedUserId) {
      throw const AuthException('Account changed during project sync.');
    }
  }

  RemoteProject _decodeRow(Map<String, dynamic> row) {
    final id = row['id'];
    final project = row['project'];
    final revision = row['revision'];
    if (id is! String || project is! Map || revision is! int) {
      throw const FormatException('Invalid project record from Supabase.');
    }
    return RemoteProject(
      id: id,
      project: Map<String, dynamic>.from(project),
      revision: revision,
    );
  }
}
