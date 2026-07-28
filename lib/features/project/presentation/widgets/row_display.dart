import 'package:flutter/material.dart';

import '../../../../core/constants/color_map.dart';
import '../../../../core/models/pattern_row.dart';
import '../../../../core/models/row_direction.dart';
import '../../../../core/theme/context_extensions.dart';

class RowDisplay extends StatelessWidget {
  const RowDisplay({
    super.key,
    required this.row,
  });

  final PatternRow row;

  @override
  Widget build(BuildContext context) {
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
                'Row ${row.rowNumber}',
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
            children: row.colorBlocks.map((block) {
              final color = getYarnColor(block.colorName);
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: color.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${block.count} ${block.colorName}',
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.brandDark,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
