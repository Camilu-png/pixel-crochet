import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_crochet/core/models/color_block.dart';
import 'package:pixel_crochet/core/models/crochet_project.dart';
import 'package:pixel_crochet/core/models/pattern_row.dart';
import 'package:pixel_crochet/core/models/row_direction.dart';
import 'package:pixel_crochet/core/storage/project_backup_service.dart';

void main() {
  group('ProjectBackupService', () {
    final service = ProjectBackupService();

    test('round-trips every project field including knitting progress', () {
      final project = CrochetProject(
        id: 'project-1',
        name: 'Butterfly',
        width: 5,
        height: 2,
        currentRowIndex: 1,
        completedBlocks: {
          0: {0, 1},
          1: {0},
        },
        createdAt: DateTime.utc(2026, 1, 2),
        doubleKnitting: true,
        rows: [
          PatternRow(
            rowNumber: 1,
            direction: RowDirection.readLeftToRight,
            colorBlocks: [
              ColorBlock(colorName: 'black', count: 2),
              ColorBlock(colorName: 'white', count: 3),
            ],
          ),
          PatternRow(
            rowNumber: 2,
            direction: RowDirection.readRightToLeft,
            colorBlocks: [ColorBlock(colorName: 'blue', count: 5)],
          ),
        ],
      );

      final restored = service.parseBackup(service.exportProjects([project]));

      expect(restored.formatVersion, 1);
      expect(restored.projects.single.toJson(), project.toJson());
    });

    test('round-trips an empty project list', () {
      final restored = service.parseBackup(service.exportProjects([]));

      expect(restored.projects, isEmpty);
    });

    test('accepts an older project schema without progress fields', () {
      final legacyProject = {
        'id': 'legacy-1',
        'name': 'Legacy',
        'width': 1,
        'height': 1,
        'rows': [
          {
            'rowNumber': 1,
            'direction': 0,
            'colorBlocks': [
              {'colorName': 'red', 'count': 1},
            ],
          },
        ],
      };
      final backup = jsonEncode({
        'formatVersion': 1,
        'exportedAt': '2025-01-01T00:00:00.000Z',
        'projects': [legacyProject],
      });

      final restored = service.parseBackup(backup).projects.single;

      expect(restored.id, 'legacy-1');
      expect(restored.currentRowIndex, 0);
      expect(restored.completedBlocks, isEmpty);
    });

    test('rejects malformed backups before returning projects', () {
      expect(() => service.parseBackup('{bad json'), throwsFormatException);
      expect(
        () => service.parseBackup(
          jsonEncode({
            'formatVersion': 1,
            'exportedAt': '2026-01-01T00:00:00.000Z',
            'projects': [null],
          }),
        ),
        throwsFormatException,
      );
    });

    test('rejects structurally invalid pattern rows', () {
      final json =
          jsonDecode(service.exportProjects([_project(name: 'Bad row')]))
              as Map<String, dynamic>;
      final projects = json['projects'] as List<dynamic>;
      final project = projects.single as Map<String, dynamic>;
      final rows = project['rows'] as List<dynamic>;
      final row = rows.first as Map<String, dynamic>;
      row['direction'] = 99;

      expect(
        () => service.parseBackup(jsonEncode(json)),
        throwsFormatException,
      );
    });

    test('preparing an invalid import leaves existing progress untouched', () {
      final existing = _project(name: 'Current work', currentRowIndex: 1);
      final originalJson = existing.toJson();

      expect(
        () => service.prepareImport(encoded: '{invalid', existing: [existing]),
        throwsFormatException,
      );

      expect(existing.toJson(), originalJson);
      expect(existing.currentRowIndex, 1);
    });

    test('rejects backups written by a newer format version', () {
      expect(
        () => service.parseBackup(
          jsonEncode({
            'formatVersion': 2,
            'exportedAt': '2026-01-01T00:00:00.000Z',
            'projects': [],
          }),
        ),
        throwsFormatException,
      );
    });

    test('keeps both revisions when an imported ID conflicts', () {
      final existing = _project(name: 'Original', currentRowIndex: 0);
      final incoming = _project(
        id: existing.id,
        name: 'Newer copy',
        currentRowIndex: 1,
      );

      final merged = service.mergeProjects(
        existing: [existing],
        imported: [incoming],
      );

      expect(merged, hasLength(2));
      expect(merged.map((project) => project.id).toSet(), hasLength(2));
      expect(merged.map((project) => project.name), contains('Original'));
      expect(merged.map((project) => project.name), contains('Newer copy'));
      expect(existing.currentRowIndex, 0);
      expect(incoming.currentRowIndex, 1);
    });

    test('does not duplicate an identical imported project', () {
      final project = _project(name: 'Same');

      final merged = service.mergeProjects(
        existing: [project],
        imported: [project.copyWith()],
      );

      expect(merged, hasLength(1));
      expect(merged.single.toJson(), project.toJson());
    });
  });
}

CrochetProject _project({
  String? id,
  required String name,
  int currentRowIndex = 0,
}) {
  return CrochetProject(
    id: id,
    name: name,
    width: 1,
    height: 2,
    currentRowIndex: currentRowIndex,
    rows: [
      PatternRow(
        rowNumber: 1,
        direction: RowDirection.readLeftToRight,
        colorBlocks: [ColorBlock(colorName: 'red', count: 1)],
      ),
      PatternRow(
        rowNumber: 2,
        direction: RowDirection.readRightToLeft,
        colorBlocks: [ColorBlock(colorName: 'blue', count: 1)],
      ),
    ],
  );
}
