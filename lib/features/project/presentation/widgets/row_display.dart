import 'package:flutter/material.dart';

import '../../../../core/constants/color_map.dart';
import '../../../../core/models/pattern_row.dart';
import '../../../../core/models/row_direction.dart';
import '../../../../core/theme/context_extensions.dart';
import '../../../../generated/app_localizations.dart';

class RowDisplay extends StatelessWidget {
  const RowDisplay({
    super.key,
    required this.row,
    this.completedBlocks = const {},
    this.onToggleBlock,
  });

  final PatternRow row;
  final Set<int> completedBlocks;
  final ValueChanged<int>? onToggleBlock;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.brandLavenderLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${l10n.rowLabel} ${row.rowNumber}',
                style: context.text.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.brandDark,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                row.direction == RowDirection.leftToRight
                    ? Icons.arrow_forward
                    : Icons.arrow_back,
                size: 16,
                color: context.colors.brandDark.withValues(alpha: 0.6),
              ),
              const Spacer(),
              Text(
                '${row.totalStitches} stitches',
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.brandDark.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: row.colorBlocks.asMap().entries.map((entry) {
              final blockIndex = entry.key;
              final block = entry.value;
              final color = getYarnColor(block.colorName);
              final isCompleted = completedBlocks.contains(blockIndex);

              return GestureDetector(
                onTap: onToggleBlock != null
                    ? () => onToggleBlock!(blockIndex)
                    : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: isCompleted ? 0.1 : 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: color.withValues(alpha: isCompleted ? 0.3 : 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: isCompleted ? 0.4 : 1.0),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${block.count} ${block.colorName}',
                        style: context.text.bodySmall?.copyWith(
                          color: context.colors.brandDark.withValues(
                            alpha: isCompleted ? 0.4 : 1.0,
                          ),
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
