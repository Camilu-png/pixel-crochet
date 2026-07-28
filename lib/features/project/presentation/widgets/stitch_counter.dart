import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/context_extensions.dart';
import '../../providers/project_provider.dart';

class StitchCounter extends ConsumerWidget {
  const StitchCounter({
    super.key,
    required this.projectId,
  });

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(stitchCounterProvider(projectId));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: context.colors.brandLavender,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: () =>
                ref.read(stitchCounterProvider(projectId).notifier).decrement(),
            icon: const Icon(Icons.remove_circle_outline),
            color: context.colors.brandDark,
            iconSize: 32,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$count',
                style: context.text.headlineLarge?.copyWith(
                  color: context.colors.brandDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Stitches',
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.brandDark.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () =>
                ref.read(stitchCounterProvider(projectId).notifier).increment(),
            icon: const Icon(Icons.add_circle_outline),
            color: context.colors.brandDark,
            iconSize: 32,
          ),
          IconButton(
            onPressed: () =>
                ref.read(stitchCounterProvider(projectId).notifier).reset(),
            icon: const Icon(Icons.refresh),
            color: context.colors.brandDark.withValues(alpha: 0.6),
          ),
        ],
      ),
    );
  }
}
