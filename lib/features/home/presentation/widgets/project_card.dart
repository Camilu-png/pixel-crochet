import 'package:flutter/material.dart';

import '../../../../core/models/crochet_project.dart';
import '../../../../core/theme/context_extensions.dart';
import '../../../../generated/app_localizations.dart';
import '../../../../shared/painters/pattern_painter.dart';

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
                          AppLocalizations.of(context)!.rowCount(
                            project.currentRowNumber,
                            project.totalRows,
                          ),
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

    final brightness = Theme.of(context).brightness;
    final highlightColor = brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.4)
        : Colors.black.withValues(alpha: 0.15);

    return CustomPaint(
      painter: PatternPainter(
        project: project,
        highlightRowIndex: project.currentRowIndex,
        highlightColor: highlightColor,
      ),
    );
  }
}
