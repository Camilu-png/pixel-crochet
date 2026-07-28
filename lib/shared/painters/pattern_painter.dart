import 'package:flutter/material.dart';

import '../../core/constants/color_map.dart';
import '../../core/models/crochet_project.dart';
import '../../core/models/row_direction.dart';

class PatternPainter extends CustomPainter {
  const PatternPainter({
    required this.project,
    this.highlightRowIndex,
    this.highlightColor,
    this.startRow = 0,
    this.endRow,
  });

  final CrochetProject project;
  final int? highlightRowIndex;
  final Color? highlightColor;
  final int startRow;
  final int? endRow;

  @override
  void paint(Canvas canvas, Size size) {
    final effectiveEnd = endRow ?? project.rows.length;
    final visibleRows = effectiveEnd - startRow;
    if (visibleRows <= 0) return;

    final pixelWidth = size.width / project.width;
    final pixelHeight = size.height / visibleRows;

    for (var i = 0; i < visibleRows; i++) {
      final rowIndex = startRow + i;
      if (rowIndex >= project.rows.length) break;

      final row = project.rows[rowIndex];
      var x = row.direction == RowDirection.leftToRight
          ? 0.0
          : size.width - pixelWidth;

      final y = (visibleRows - 1 - i) * pixelHeight;

      for (final block in row.colorBlocks) {
        final color = getYarnColor(block.colorName);
        final paint = Paint()..color = color;

        for (var j = 0; j < block.count; j++) {
          canvas.drawRect(
            Rect.fromLTWH(x, y, pixelWidth, pixelHeight),
            paint,
          );

          x += row.direction == RowDirection.leftToRight
              ? pixelWidth
              : -pixelWidth;
        }
      }

      if (rowIndex == highlightRowIndex) {
        final hColor = highlightColor ?? Colors.white.withValues(alpha: 0.3);
        final highlightPaint = Paint()
          ..color = hColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

        canvas.drawRect(
          Rect.fromLTWH(0, y, size.width, pixelHeight),
          highlightPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant PatternPainter oldDelegate) {
    return oldDelegate.highlightRowIndex != highlightRowIndex ||
        oldDelegate.highlightColor != highlightColor ||
        oldDelegate.startRow != startRow ||
        oldDelegate.endRow != endRow ||
        oldDelegate.project != project;
  }
}
