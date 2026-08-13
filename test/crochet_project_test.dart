import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_crochet/core/models/color_block.dart';
import 'package:pixel_crochet/core/models/crochet_project.dart';
import 'package:pixel_crochet/core/models/pattern_row.dart';
import 'package:pixel_crochet/core/models/row_direction.dart';

void main() {
  group('CrochetProject', () {
    CrochetProject createProject({
      int width = 5,
      int height = 3,
      int currentRowIndex = 0,
      Map<int, Set<int>>? completedBlocks,
    }) {
      final rows = List.generate(
        height,
        (i) => PatternRow(
          rowNumber: i + 1,
          direction: RowDirection.readLeftToRight,
          colorBlocks: [ColorBlock(colorName: 'black', count: width)],
        ),
      );
      return CrochetProject(
        name: 'Test',
        width: width,
        height: height,
        rows: rows,
        currentRowIndex: currentRowIndex,
        completedBlocks: completedBlocks,
      );
    }

    group('toJson / fromJson round-trip', () {
      test('preserves all fields', () {
        final project = CrochetProject(
          name: 'Round Trip Test',
          width: 10,
          height: 2,
          rows: [
            PatternRow(
              rowNumber: 1,
              direction: RowDirection.readLeftToRight,
              colorBlocks: [
                ColorBlock(colorName: 'black', count: 3),
                ColorBlock(colorName: 'white', count: 7),
              ],
            ),
            PatternRow(
              rowNumber: 2,
              direction: RowDirection.readRightToLeft,
              colorBlocks: [ColorBlock(colorName: 'red', count: 10)],
            ),
          ],
          completedBlocks: {0: {0, 1}, 1: {0}},
        );

        final json = project.toJson();
        final restored = CrochetProject.fromJson(json);

        expect(restored.id, project.id);
        expect(restored.name, project.name);
        expect(restored.width, project.width);
        expect(restored.height, project.height);
        expect(restored.currentRowIndex, project.currentRowIndex);
        expect(restored.completedBlocks, project.completedBlocks);
        expect(restored.createdAt.toIso8601String(),
            project.createdAt.toIso8601String());
        expect(restored.rows.length, project.rows.length);
        expect(restored.rows[0].direction, project.rows[0].direction);
        expect(restored.rows[0].colorBlocks.length,
            project.rows[0].colorBlocks.length);
      });

      test('handles empty completed blocks', () {
        final project = createProject();

        final json = project.toJson();
        final restored = CrochetProject.fromJson(json);

        expect(restored.completedBlocks, isEmpty);
      });

      test('handles null completedBlocks in JSON', () {
        final project = createProject();
        final json = project.toJson();
        json.remove('completedBlocks');

        final restored = CrochetProject.fromJson(json);

        expect(restored.completedBlocks, isEmpty);
      });
    });

    group('toggleBlock', () {
      test('marks a block as completed', () {
        final project = createProject();

        final updated = project.toggleBlock(0, 0);

        expect(updated.completedBlocks[0], contains(0));
        expect(project.completedBlocks, isEmpty,
            reason: 'original should be unchanged');
      });

      test('unmarks a completed block', () {
        final project = createProject(completedBlocks: {0: {0}});

        final updated = project.toggleBlock(0, 0);

        expect(updated.completedBlocks, isEmpty);
      });

      test('multiple blocks can be toggled', () {
        final project = CrochetProject(
          name: 'Multi',
          width: 3,
          height: 1,
          rows: [
            PatternRow(
              rowNumber: 1,
              direction: RowDirection.readLeftToRight,
              colorBlocks: [
                ColorBlock(colorName: 'red', count: 1),
                ColorBlock(colorName: 'blue', count: 1),
                ColorBlock(colorName: 'green', count: 1),
              ],
            ),
          ],
        );

        var updated = project.toggleBlock(0, 0);
        updated = updated.toggleBlock(0, 0);
        expect(updated.completedBlocks, isEmpty,
            reason: 'toggle on then off should be empty');

        updated = project.toggleBlock(0, 0);
        updated = updated.toggleBlock(0, 1);
        expect(updated.completedBlocks[0]!.length, 2,
            reason: 'two blocks toggled on');
      });

      test('removes empty set from map', () {
        final project = createProject(completedBlocks: {0: {0}});

        final updated = project.toggleBlock(0, 0);

        expect(updated.completedBlocks.containsKey(0), false);
      });
    });

    group('progress', () {
      test('starts at 0 for no completed blocks', () {
        final project = createProject(width: 5, height: 3);

        expect(project.progress, 0.0);
      });

      test('returns correct fraction for partial completion', () {
        final project = CrochetProject(
          name: 'Partial',
          width: 3,
          height: 2,
          rows: [
            PatternRow(
              rowNumber: 1,
              direction: RowDirection.readLeftToRight,
              colorBlocks: [
                ColorBlock(colorName: 'red', count: 1),
                ColorBlock(colorName: 'blue', count: 1),
                ColorBlock(colorName: 'green', count: 1),
              ],
            ),
            PatternRow(
              rowNumber: 2,
              direction: RowDirection.readRightToLeft,
              colorBlocks: [
                ColorBlock(colorName: 'white', count: 3),
              ],
            ),
          ],
          completedBlocks: {0: {0, 1}},
        );

        expect(project.progress, 2.0 / 4.0);
      });

      test('returns 1.0 for all blocks completed', () {
        final project = CrochetProject(
          name: 'Full',
          width: 2,
          height: 2,
          rows: [
            PatternRow(
              rowNumber: 1,
              direction: RowDirection.readLeftToRight,
              colorBlocks: [
                ColorBlock(colorName: 'black', count: 2),
              ],
            ),
            PatternRow(
              rowNumber: 2,
              direction: RowDirection.readRightToLeft,
              colorBlocks: [
                ColorBlock(colorName: 'white', count: 2),
              ],
            ),
          ],
          completedBlocks: {0: {0}, 1: {0}},
        );

        expect(project.progress, 1.0);
      });
    });

    group('isCompleted', () {
      test('is false when no blocks completed', () {
        final project = createProject(height: 3, currentRowIndex: 2);

        expect(project.isCompleted, false);
      });

      test('is true when all blocks completed', () {
        final project = CrochetProject(
          name: 'Done',
          width: 1,
          height: 1,
          rows: [
            PatternRow(
              rowNumber: 1,
              direction: RowDirection.readLeftToRight,
              colorBlocks: [ColorBlock(colorName: 'black', count: 3)],
            ),
          ],
          completedBlocks: {0: {0}},
        );

        expect(project.isCompleted, true);
      });

      test('is false when only some blocks completed', () {
        final project = CrochetProject(
          name: 'Partial',
          width: 1,
          height: 1,
          rows: [
            PatternRow(
              rowNumber: 1,
              direction: RowDirection.readLeftToRight,
              colorBlocks: [
                ColorBlock(colorName: 'black', count: 2),
                ColorBlock(colorName: 'white', count: 2),
              ],
            ),
          ],
          completedBlocks: {0: {0}},
        );

        expect(project.isCompleted, false);
      });
    });

    group('isBlockCompleted', () {
      test('returns false for uncompleted block', () {
        final project = createProject();
        expect(project.isBlockCompleted(0, 0), false);
      });

      test('returns true for completed block', () {
        final project = createProject(completedBlocks: {0: {0}});
        expect(project.isBlockCompleted(0, 0), true);
      });

      test('returns false for out-of-range row', () {
        final project = createProject();
        expect(project.isBlockCompleted(99, 0), false);
      });
    });

    group('copyWith', () {
      test('creates independent deep copy of completedBlocks', () {
        final project = createProject(completedBlocks: {0: {0}});
        final copied = project.copyWith();
        copied.completedBlocks[0]!.add(1);

        expect(project.completedBlocks[0]!.length, 1,
            reason: 'original should not be affected by mutation of copy');
      });

      test('creates independent deep copy of rows', () {
        final project = createProject();
        final copied = project.copyWith();

        expect(identical(copied.rows, project.rows), false,
            reason: 'rows list should be a different instance');
      });
    });

    group('totalCompletedBlocks', () {
      test('returns 0 for no completed blocks', () {
        final project = createProject();
        expect(project.totalCompletedBlocks, 0);
      });

      test('counts blocks across rows', () {
        final project = createProject(
          completedBlocks: {0: {0, 1}, 1: {0}},
        );
        expect(project.totalCompletedBlocks, 3);
      });
    });
  });
}
