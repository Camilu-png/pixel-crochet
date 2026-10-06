abstract interface class ProjectSyncRemote {
  String? get userId;

  Future<List<RemoteProject>> listProjects({required String userId});

  Future<RemoteProject?> insertProject({
    required String userId,
    required Map<String, dynamic> project,
  });

  Future<RemoteProject?> updateProject({
    required String userId,
    required String id,
    required int expectedRevision,
    required Map<String, dynamic> project,
  });

  Future<bool> deleteProject({
    required String userId,
    required String id,
    required int expectedRevision,
  });
}

class RemoteProject {
  RemoteProject({
    required this.id,
    required Map<String, dynamic> project,
    required this.revision,
  }) : project = Map<String, dynamic>.from(project);

  final String id;
  final Map<String, dynamic> project;
  final int revision;
}
