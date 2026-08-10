import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_crochet/core/models/row_direction.dart';
import 'package:pixel_crochet/features/import_image/data/image_processor.dart';

const _black = Color(0xFF2D2D2D);
const _white = Color(0xFFF5F5F5);
const _red = Color(0xFFE53935);
const _green = Color(0xFF43A047);
const _blue = Color(0xFF1E88E5);

void main() {
  final processor = ImageProcessor();

  group('ImageProcessor.generateProject', () {
    test('orients rows so first project row is the bottom of the image', () {
      // 3 rows x 3 cols matrix; row 0 = top of image, row 2 = bottom.
      final matrix = <List<Color>>[
        [_black, _white, _black],
        [_white, _black, _white],
        [_black, _black, _white],
      ];

      final project = processor.generateProject('Test', matrix);

      expect(project.height, 3);
      expect(project.rows.length, 3);

      // rows[0] must be the bottom row of the image (matrix[2]), LTR.
      expect(project.rows[0].rowNumber, 1);
      expect(project.rows[0].direction, RowDirection.leftToRight);
      expect(project.rows[0].totalStitches, 3);
      expect(project.rows[0].colorBlocks.map((b) => b.colorName), [
        'black',
        'white',
      ]);
      expect(project.rows[0].colorBlocks[0].count, 2);
      expect(project.rows[0].colorBlocks[1].count, 1);

      // rows[2] must be the top row of the image (matrix[0]).
      expect(project.rows[2].rowNumber, 3);
      expect(project.rows[2].colorBlocks.map((b) => b.colorName), [
        'black',
        'white',
        'black',
      ]);
    });

    test('alternates row direction starting left-to-right', () {
      final matrix = List.generate(4, (_) {
        return List.generate(2, (_) => _black);
      });

      final project = processor.generateProject('Test', matrix);

      expect(project.rows[0].direction, RowDirection.leftToRight);
      expect(project.rows[1].direction, RowDirection.rightToLeft);
      expect(project.rows[2].direction, RowDirection.leftToRight);
      expect(project.rows[3].direction, RowDirection.rightToLeft);
    });

    test('groups consecutive same-color cells into a single block', () {
      final matrix = <List<Color>>[
        [_red, _red, _blue],
      ];

      final project = processor.generateProject('Test', matrix);

      final row = project.rows[0];
      expect(row.colorBlocks.length, 2);
      expect(row.colorBlocks[0].colorName, 'red');
      expect(row.colorBlocks[0].count, 2);
      expect(row.colorBlocks[1].colorName, 'blue');
      expect(row.colorBlocks[1].count, 1);
    });

    test('preserves horizontal order for left-to-right rows', () {
      final matrix = <List<Color>>[
        [_red, _green, _blue],
      ];

      final project = processor.generateProject('Test', matrix);

      final row = project.rows[0];
      expect(row.direction, RowDirection.leftToRight);
      expect(row.colorBlocks.map((b) => b.colorName).toList(), [
        'red',
        'green',
        'blue',
      ]);
    });
  });
}
