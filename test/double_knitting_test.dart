import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_crochet/core/models/color_block.dart';
import 'package:pixel_crochet/core/models/crochet_project.dart';
import 'package:pixel_crochet/core/models/double_knitting.dart';
import 'package:pixel_crochet/core/models/pattern_row.dart';
import 'package:pixel_crochet/core/models/row_direction.dart';

void main() {
  const swap = {'negro': 'blanco', 'blanco': 'negro'};

  group('buildColorSwap', () {
    test('exchanges the two colors when the project uses exactly two', () {
      expect(buildColorSwap(const ['negro', 'blanco']), {
        'negro': 'blanco',
        'blanco': 'negro',
      });
    });
  });

  group('swapRowColors', () {
    test('exchanges colors on a left-to-right row keeping block counts', () {
      const row = PatternRow(
        rowNumber: 1,
        direction: RowDirection.readLeftToRight,
        colorBlocks: [
          ColorBlock(colorName: 'negro', count: 1),
          ColorBlock(colorName: 'blanco', count: 4),
          ColorBlock(colorName: 'negro', count: 3),
        ],
      );

      final swapped = swapRowColors(row, swap);

      expect(swapped.colorBlocks, const [
        ColorBlock(colorName: 'blanco', count: 1),
        ColorBlock(colorName: 'negro', count: 4),
        ColorBlock(colorName: 'blanco', count: 3),
      ]);
      expect(swapped.totalStitches, 8);
    });

    test('exchanges a right-to-left row too', () {
      const row = PatternRow(
        rowNumber: 2,
        direction: RowDirection.readRightToLeft,
        colorBlocks: [ColorBlock(colorName: 'negro', count: 2)],
      );

      expect(swapRowColors(row, swap).colorBlocks, const [
        ColorBlock(colorName: 'blanco', count: 2),
      ]);
    });
  });

  group('distinctProjectColors', () {
    test('reports each color once across every row', () {
      final project = CrochetProject(
        name: 'muestra',
        width: 3,
        height: 2,
        rows: const [
          PatternRow(
            rowNumber: 1,
            direction: RowDirection.readLeftToRight,
            colorBlocks: [
              ColorBlock(colorName: 'negro', count: 1),
              ColorBlock(colorName: 'blanco', count: 4),
              ColorBlock(colorName: 'negro', count: 3),
            ],
          ),
          PatternRow(
            rowNumber: 2,
            direction: RowDirection.readRightToLeft,
            colorBlocks: [ColorBlock(colorName: 'blanco', count: 2)],
          ),
        ],
      );

      expect(distinctProjectColors(project), {'negro', 'blanco'});
    });
  });
}
