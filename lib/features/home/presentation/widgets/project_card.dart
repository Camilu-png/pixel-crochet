import 'package:flutter/material.dart';

import '../../../../core/constants/color_map.dart';
import '../../../../core/models/crochet_project.dart';
import '../../../../core/models/row_direction.dart';
import '../../../../core/theme/context_extensions.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
    required this.onDelete,
  });

  final CrochetProject project;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _PatternPreview(project: project),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.name,
                          style: context.text.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${project.currentRowNumber}/${project.totalRows} rows',
                          style: context.text.bodySmall?.copyWith(
                            color: context.colors.brandDark.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: onDelete,
                    color: context.colors.brandDark.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PatternPreview extends StatelessWidget {
  const _PatternPreview({required this.project});

  final CrochetProject project;

  @override
  Widget build(BuildContext context) {
    if (project.rows.isEmpty) {
      return Container(
        color: context.colors.brandTanLight,
        child: Icon(
          Icons.pattern,
          color: context.colors.brandDark.withValues(alpha: 0.2),
        ),
      );
    }

    return CustomPaint(
      painter: _PatternPainter(project: project),
      child: Container(),
    );
  }
}

class _PatternPainter extends CustomPainter {
  const _PatternPainter({required this.project});

  final CrochetProject project;

  @override
  void paint(Canvas canvas, Size size) {
    final pixelWidth = size.width / project.width;
    final pixelHeight = size.height / project.rows.length;

    for (var rowIndex = 0; rowIndex < project.rows.length; rowIndex++) {
      final row = project.rows[rowIndex];
      var x = row.direction == RowDirection.leftToRight
          ? 0.0
          : size.width;

      for (final block in row.colorBlocks) {
        final color = getYarnColor(block.colorName);
        final paint = Paint()..color = color;

        for (var i = 0; i < block.count; i++) {
          final rect = Rect.fromLTWH(
            x,
            rowIndex * pixelHeight,
            pixelWidth,
            pixelHeight,
          );
          canvas.drawRect(rect, paint);

          x += row.direction == RowDirection.leftToRight
              ? pixelWidth
              : -pixelWidth;
        }
      }
    }

    // Highlight current row
    if (project.currentRowIndex < project.rows.length) {
      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      final rect = Rect.fromLTWH(
        0,
        project.currentRowIndex * pixelHeight,
        size.width,
        pixelHeight,
      );
      canvas.drawRect(rect, highlightPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PatternPainter oldDelegate) {
    return oldDelegate.project.currentRowIndex != project.currentRowIndex;
  }
}
