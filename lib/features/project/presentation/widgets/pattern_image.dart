import 'package:flutter/material.dart';

import '../../../../core/models/crochet_project.dart';
import '../../../../core/theme/context_extensions.dart';
import '../../../../shared/painters/pattern_painter.dart';

class PatternImage extends StatelessWidget {
  const PatternImage({
    super.key,
    required this.project,
    this.highlightRowIndex,
  });

  final CrochetProject project;
  final int? highlightRowIndex;

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

    return LayoutBuilder(
      builder: (context, constraints) {
        final pixelSize = constraints.maxWidth / project.width;
        final imageHeight = project.rows.length * pixelSize;

        return SingleChildScrollView(
          child: CustomPaint(
            size: Size(constraints.maxWidth, imageHeight),
            painter: PatternPainter(
              project: project,
              highlightRowIndex: highlightRowIndex,
            ),
          ),
        );
      },
    );
  }
}
