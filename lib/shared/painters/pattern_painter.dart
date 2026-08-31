import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/constants/color_map.dart';
import '../../core/models/crochet_project.dart';
import '../../core/models/row_direction.dart';

class PatternPainter extends CustomPainter {
  const PatternPainter({
    required this.project,
    this.highlightRowIndex,
    this.highlightColor,
    this.highlightFillColor,
    this.startRow = 0,
    this.endRow,
  });

  final CrochetProject project;
  final int? highlightRowIndex;
  final Color? highlightColor;
  final Color? highlightFillColor;
  final int startRow;
  final int? endRow;

  @override
  void paint(Canvas canvas, Size size) {
    final effectiveEnd = endRow ?? project.rows.length;
    final visibleRows = effectiveEnd - startRow;
    if (visibleRows <= 0 || project.width <= 0) return;

    final pixelWidth = size.width / project.width;
    final pixelHeight = size.height / visibleRows;

    for (var i = 0; i < visibleRows; i++) {
      final rowIndex = startRow + i;
      if (rowIndex >= project.rows.length) break;

      final row = project.rows[rowIndex];
      var x = row.direction == RowDirection.readLeftToRight
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

          x += row.direction == RowDirection.readLeftToRight
              ? pixelWidth
              : -pixelWidth;
        }
      }

      if (rowIndex == highlightRowIndex) {
        final hColor = highlightColor ?? Colors.white.withValues(alpha: 0.3);
        final hFillColor = highlightFillColor ?? hColor.withValues(alpha: 0.1);

        final glowPaint = Paint()
          ..color = hColor.withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawRect(
          Rect.fromLTWH(-4, y - 4, size.width + 8, pixelHeight + 8),
          glowPaint,
        );

        final fillPaint = Paint()..color = hFillColor;
        canvas.drawRect(
          Rect.fromLTWH(0, y, size.width, pixelHeight),
          fillPaint,
        );

        final strokePaint = Paint()
          ..color = hColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;

        canvas.drawRect(
          Rect.fromLTWH(0, y, size.width, pixelHeight),
          strokePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant PatternPainter oldDelegate) {
    return oldDelegate.highlightRowIndex != highlightRowIndex ||
        oldDelegate.highlightColor != highlightColor ||
        oldDelegate.highlightFillColor != highlightFillColor ||
        oldDelegate.startRow != startRow ||
        oldDelegate.endRow != endRow ||
        oldDelegate.project.width != project.width ||
        !listEquals(oldDelegate.project.rows, project.rows) ||
        !_sameCompletedBlocks(
            oldDelegate.project.completedBlocks, project.completedBlocks);
  }

  bool _sameCompletedBlocks(
    Map<int, Set<int>> a,
    Map<int, Set<int>> b,
  ) {
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      final other = b[entry.key];
      if (other == null || !setEquals(entry.value, other)) return false;
    }
    return true;
  }
}
