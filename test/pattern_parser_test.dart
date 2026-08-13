import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_crochet/core/models/row_direction.dart';
import 'package:pixel_crochet/features/import_pattern/data/pattern_parser.dart';

void main() {
  final parser = const PatternParser();

  group('PatternParser.parse', () {
    test('parses a valid pattern', () {
      final input = 'My Pattern\n10 x 5\n'
          'Row 1 <-: 5 black, 5 white\n'
          'Row 2 ->: 10 white\n'
          'Row 3 <-: 3 red, 4 green, 3 red\n'
          'Row 4 ->: 10 white\n'
          'Row 5 <-: 5 black, 5 white\n';

      final project = parser.parse(input);

      expect(project.name, 'My Pattern');
      expect(project.width, 10);
      expect(project.height, 5);
      expect(project.rows.length, 5);
      expect(project.rows[0].rowNumber, 1);
      expect(project.rows[0].direction, RowDirection.readLeftToRight);
      expect(project.rows[0].colorBlocks.length, 2);
      expect(project.rows[0].colorBlocks[0].colorName, 'black');
      expect(project.rows[0].colorBlocks[0].count, 5);
      expect(project.rows[0].colorBlocks[1].colorName, 'white');
      expect(project.rows[0].colorBlocks[1].count, 5);
      expect(project.rows[1].direction, RowDirection.readRightToLeft);
      expect(project.rows[4].direction, RowDirection.readLeftToRight);
      expect(project.rows[4].rowNumber, 5);
    });

    test('throws on too few lines', () {
      expect(
        () => parser.parse('Name\n'),
        throwsFormatException,
      );
    });

    test('throws on empty after non-empty rows', () {
      expect(
        () => parser.parse('Name\n10 x 10\n'),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws on row count mismatch', () {
      final input = 'Name\n5 x 5\nRow 1 <-: 5 black\n';

      expect(
        () => parser.parse(input),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws on invalid dimensions', () {
      final input = 'Name\ninvalid\nRow 1 <-: 5 black\n';

      expect(
        () => parser.parse(input),
        throwsA(isA<FormatException>()),
      );
    });

    test('handles whitespace in block colors', () {
      final input = 'Test\n3 x 1\nRow 1 <-: 1 black, 2 white\n';

      final project = parser.parse(input);

      expect(project.rows[0].colorBlocks[1].colorName, 'white');
      expect(project.rows[0].colorBlocks[1].count, 2);
    });

    test('handles many blocks in a row', () {
      final input = 'Multi\n5 x 1\nRow 1 <-: 1 red, 1 blue, 1 green, 1 yellow, 1 black\n';

      final project = parser.parse(input);

      expect(project.rows[0].colorBlocks.length, 5);
      expect(project.rows[0].totalStitches, 5);
    });
  });

  group('PatternParser edge cases', () {
    test('ignores empty lines', () {
      final input = 'My Pattern\n10 x 5\n\nRow 1 <-: 5 black, 5 white\n\n\n'
          'Row 2 ->: 10 white\nRow 3 <-: 10 black\n'
          'Row 4 ->: 10 white\nRow 5 <-: 10 black\n';

      final project = parser.parse(input);

      expect(project.rows.length, 5);
    });

    test('parses single-row pattern', () {
      final input = 'Single\n1 x 1\nRow 1 <-: 1 red\n';

      final project = parser.parse(input);

      expect(project.rows.length, 1);
      expect(project.width, 1);
      expect(project.height, 1);
    });
  });
}
