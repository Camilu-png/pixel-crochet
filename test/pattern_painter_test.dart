import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_crochet/core/models/color_block.dart';
import 'package:pixel_crochet/core/models/crochet_project.dart';
import 'package:pixel_crochet/core/models/pattern_row.dart';
import 'package:pixel_crochet/core/models/row_direction.dart';
import 'package:pixel_crochet/shared/painters/pattern_painter.dart';

void main() {
  CrochetProject project() => CrochetProject(
        name: 'Paint',
        width: 2,
        height: 1,
        rows: [
          PatternRow(
            rowNumber: 1,
            direction: RowDirection.readLeftToRight,
            colorBlocks: [
              ColorBlock(colorName: 'black', count: 1),
              ColorBlock(colorName: 'white', count: 1),
            ],
          ),
        ],
      );

  test('shouldRepaint is false for identical projects', () {
    final painter = PatternPainter(project: project());
    final other = PatternPainter(project: project());

    expect(painter.shouldRepaint(other), isFalse);
  });

  test('shouldRepaint is true when the highlight row changes', () {
    final painter = PatternPainter(project: project(), highlightRowIndex: 0);
    final other = PatternPainter(project: project(), highlightRowIndex: 1);

    expect(painter.shouldRepaint(other), isTrue);
  });

  test('shouldRepaint is true when completed blocks change', () {
    final painter = PatternPainter(project: project());
    final updated = PatternPainter(project: project().toggleBlock(0, 0));

    expect(painter.shouldRepaint(updated), isTrue);
  });
}
