import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../models/crochet_project.dart';

class BackupImportResult {
  const BackupImportResult({
    required this.formatVersion,
    required this.exportedAt,
    required this.projects,
  });

  final int formatVersion;
  final DateTime exportedAt;
  final List<CrochetProject> projects;
}

/// Encodes and validates portable copies of the locally stored projects.
///
/// Parsing is intentionally pure: callers must validate the complete file and
/// ask the person before writing any of its projects to local storage.
class ProjectBackupService {
  static const int currentFormatVersion = 1;

  String exportProjects(List<CrochetProject> projects) {
    return const JsonEncoder.withIndent('  ').convert({
      'formatVersion': currentFormatVersion,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'projects': projects.map((project) => project.toJson()).toList(),
    });
  }

  BackupImportResult parseBackup(String encoded) {
    final dynamic decoded;
    try {
      decoded = jsonDecode(encoded);
    } on FormatException {
      throw const FormatException('The backup is not valid JSON.');
    }
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('The backup must be a JSON object.');
    }

    final version = decoded['formatVersion'];
    if (version is! int || version < 1 || version > currentFormatVersion) {
      throw FormatException('Unsupported backup format version: $version.');
    }
    final exportedAtValue = decoded['exportedAt'];
    final exportedAt = exportedAtValue is String
        ? DateTime.tryParse(exportedAtValue)
        : null;
    if (exportedAt == null) {
      throw const FormatException('The backup has no valid export date.');
    }
    final rawProjects = decoded['projects'];
    if (rawProjects is! List) {
      throw const FormatException('The backup projects field must be a list.');
    }

    final projects = <CrochetProject>[];
    for (var index = 0; index < rawProjects.length; index++) {
      final rawProject = rawProjects[index];
      if (rawProject is! Map<String, dynamic>) {
        throw FormatException('Project ${index + 1} is not a valid object.');
      }
      _validateProject(rawProject, index);
      try {
        projects.add(CrochetProject.fromJson(rawProject));
      } on FormatException catch (error) {
        throw FormatException('Project ${index + 1} is not supported: $error');
      }
    }

    return BackupImportResult(
      formatVersion: version,
      exportedAt: exportedAt,
      projects: List.unmodifiable(projects),
    );
  }

  /// Validates a backup and prepares its additions without changing [existing].
  List<CrochetProject> prepareImport({
    required String encoded,
    required List<CrochetProject> existing,
    String Function()? idFactory,
  }) {
    final backup = parseBackup(encoded);
    return mergeProjects(
      existing: existing,
      imported: backup.projects,
      idFactory: idFactory,
    );
  }

  /// Combines a validated import without replacing any conflicting project.
  ///
  /// Identical records are skipped. If an ID is already used by different
  /// content, the incoming project is copied with a new ID and its progress
  /// intact. [idFactory] is injectable to keep collision behavior testable.
  List<CrochetProject> mergeProjects({
    required List<CrochetProject> existing,
    required List<CrochetProject> imported,
    String Function()? idFactory,
  }) {
    final makeId = idFactory ?? const Uuid().v4;
    final merged = [...existing];
    final byId = {for (final project in merged) project.id: project};

    for (final project in imported) {
      final previous = byId[project.id];
      if (previous == null) {
        merged.add(project);
        byId[project.id] = project;
        continue;
      }
      if (_sameProject(previous, project)) continue;

      String newId;
      do {
        newId = makeId();
      } while (byId.containsKey(newId));
      final copy = _copyWithId(project, newId);
      merged.add(copy);
      byId[newId] = copy;
    }

    return List.unmodifiable(merged);
  }

  bool _sameProject(CrochetProject left, CrochetProject right) =>
      jsonEncode(left.toJson()) == jsonEncode(right.toJson());

  CrochetProject _copyWithId(CrochetProject project, String id) {
    return CrochetProject(
      id: id,
      name: project.name,
      width: project.width,
      height: project.height,
      rows: project.rows,
      currentRowIndex: project.currentRowIndex,
      completedBlocks: project.completedBlocks,
      createdAt: project.createdAt,
      doubleKnitting: project.doubleKnitting,
    );
  }

  void _validateProject(Map<String, dynamic> json, int index) {
    FormatException invalid(String detail) =>
        FormatException('Project ${index + 1} $detail.');

    if (json['id'] is! String || (json['id'] as String).isEmpty) {
      throw invalid('must have a non-empty ID');
    }
    if (json['name'] is! String || (json['name'] as String).isEmpty) {
      throw invalid('must have a name');
    }
    if (json['width'] is! int ||
        json['height'] is! int ||
        (json['width'] as int) <= 0 ||
        (json['height'] as int) <= 0) {
      throw invalid('must have integer dimensions');
    }
    final rows = json['rows'];
    if (rows is! List) throw invalid('must have a rows list');
    for (final row in rows) {
      if (row is! Map<String, dynamic> ||
          row['rowNumber'] is! int ||
          (row['rowNumber'] as int) <= 0 ||
          row['direction'] is! int ||
          (row['direction'] as int) < 0 ||
          (row['direction'] as int) >= 2 ||
          row['colorBlocks'] is! List) {
        throw invalid('contains an invalid row');
      }
      for (final block in row['colorBlocks'] as List) {
        if (block is! Map<String, dynamic> ||
            block['colorName'] is! String ||
            block['count'] is! int ||
            (block['count'] as int) <= 0) {
          throw invalid('contains an invalid color block');
        }
      }
    }

    final version = json['version'];
    if (version != null && version is! int) {
      throw invalid('has an invalid schema version');
    }
    if (json['currentRowIndex'] != null && json['currentRowIndex'] is! int) {
      throw invalid('has an invalid current row');
    }
    final completedBlocks = json['completedBlocks'];
    if (completedBlocks != null) {
      if (completedBlocks is! Map) {
        throw invalid('has invalid completed blocks');
      }
      for (final entry in completedBlocks.entries) {
        if (int.tryParse('${entry.key}') == null ||
            entry.value is! List ||
            (entry.value as List).any((block) => block is! int)) {
          throw invalid('has invalid completed blocks');
        }
      }
    }
    if (json['createdAt'] != null &&
        (json['createdAt'] is! String ||
            DateTime.tryParse(json['createdAt'] as String) == null)) {
      throw invalid('has an invalid creation date');
    }
    if (json['doubleKnitting'] != null && json['doubleKnitting'] is! bool) {
      throw invalid('has an invalid knitting option');
    }
  }
}
