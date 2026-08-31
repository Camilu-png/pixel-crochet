import 'package:flutter/material.dart';

import '../../../../core/models/crochet_project.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../generated/app_localizations.dart';
import '../../../../shared/painters/pattern_painter.dart';

class ProjectCard extends StatefulWidget {
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
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final texts = context.texts;
    final l10n = AppLocalizations.of(context)!;
    final p = widget.project;
    final progress = p.totalRows == 0 ? 0.0 : p.currentRowNumber / p.totalRows;

    return AnimatedScale(
      scale: _pressed ? 0.97 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          boxShadow: brand.softShadow,
        ),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            onLongPress: () => _confirmDelete(context),
            onHighlightChanged: (v) => setState(() => _pressed = v),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _PatternPreview(project: p),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: _GlassIconButton(
                          icon: Icons.more_vert_rounded,
                          tooltip: l10n.optionsLabel,
                          onPressed: () => _confirmDelete(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: texts.titleMedium,
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Stack(
                          children: [
                            Container(height: 6, color: brand.lavenderSoft),
                            FractionallySizedBox(
                              widthFactor: progress.clamp(0, 1),
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  gradient: brand.progressGradient,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.rowCounter(
                          p.currentRowNumber,
                          p.totalRows,
                          (progress * 100).round(),
                        ),
                        style: texts.labelSmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.delete_outline_rounded, color: ctx.brand.danger),
        title: Text(l10n.deletePatternTitle),
        content: Text(l10n.deletePatternBody(widget.project.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: ctx.brand.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (ok ?? false) widget.onDelete();
  }
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      tooltip: tooltip,
      onPressed: onPressed,
      iconSize: 20,
      constraints: const BoxConstraints.tightFor(width: 40, height: 40),
      style: IconButton.styleFrom(
        backgroundColor: context.scheme.surface.withValues(alpha: .82),
        foregroundColor: context.brand.ink,
      ),
      icon: Icon(icon),
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
        color: context.brand.tanSoft,
        child: Icon(
          Icons.pattern,
          color: context.brand.ink.withValues(alpha: 0.2),
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
