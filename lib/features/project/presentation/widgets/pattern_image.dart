import 'package:flutter/material.dart';

import '../../../../core/constants/color_map.dart';
import '../../../../core/models/crochet_project.dart';
import '../../../../core/models/row_direction.dart';
import '../../../../core/theme/context_extensions.dart';

class PatternImage extends StatelessWidget {
  const PatternImage({
    super.key,
    required this.project,
    this.highlightRowIndex,
    this.visibleRowRange,
  });

  final CrochetProject project;
  final int? highlightRowIndex;
  final (int start, int end)? visibleRowRange;

  @override
  Widget build(BuildContext context) {
    if (project.rows.isEmpty) {
      return Center(
        child: Text(
          'No pattern data',
          style: context.text.bodyLarge?.copyWith(
            color: context.colors.brandDark.withValues(alpha: 0.5),
          ),
        ),
      );
    }

    final startRow = visibleRowRange?.$1 ?? 0;
    final endRow = visibleRowRange?.$2 ?? project.rows.length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: CustomPaint(
          size: Size(
            project.width * 4.0,
            (endRow - startRow) * 4.0,
          ),
          painter: _PatternPainter(
            project: project,
            startRow: startRow,
            endRow: endRow,
            highlightRowIndex: highlightRowIndex,
          ),
        ),
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  const _PatternPainter({
    required this.project,
    required this.startRow,
    required this.endRow,
    this.highlightRowIndex,
  });

  final CrochetProject project;
  final int startRow;
  final int endRow;
  final int? highlightRowIndex;

  @override
  void paint(Canvas canvas, Size size) {
    final pixelWidth = size.width / project.width;
    final visibleRows = endRow - startRow;
    final pixelHeight = size.height / visibleRows;

    for (var i = 0; i < visibleRows; i++) {
      final rowIndex = startRow + i;
      if (rowIndex >= project.rows.length) break;

      final row = project.rows[rowIndex];
      var x = row.direction == RowDirection.leftToRight
          ? 0.0
          : size.width;

      for (final block in row.colorBlocks) {
        final color = getYarnColor(block.colorName);
        final paint = Paint()..color = color;

        for (var j = 0; j < block.count; j++) {
          final rect = Rect.fromLTWH(
            x,
            i * pixelHeight,
            pixelWidth,
            pixelHeight,
          );
          canvas.drawRect(rect, paint);

          x += row.direction == RowDirection.leftToRight
              ? pixelWidth
              : -pixelWidth;
        }
      }

      // Highlight current row
      if (rowIndex == highlightRowIndex) {
        final highlightPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

        final rect = Rect.fromLTWH(
          0,
          i * pixelHeight,
          size.width,
          pixelHeight,
        );
        canvas.drawRect(rect, highlightPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PatternPainter oldDelegate) {
    return oldDelegate.highlightRowIndex != highlightRowIndex ||
        oldDelegate.startRow != startRow ||
        oldDelegate.endRow != endRow;
  }
}
