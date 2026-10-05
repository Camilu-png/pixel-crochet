import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_crochet/core/constants/products.dart';
import 'package:pixel_crochet/core/theme/app_colors.dart';
import 'package:pixel_crochet/core/theme/app_theme.dart';
import 'package:pixel_crochet/features/home/providers/home_provider.dart';
import 'package:pixel_crochet/features/more_patterns/data/free_pattern_catalog.dart';
import 'package:pixel_crochet/shared/painters/pattern_painter.dart';
import 'package:pixel_crochet/shared/widgets/kofi_button.dart';
import 'package:pixel_crochet/shared/layout/grid_columns.dart';

import '../../../../generated/app_localizations.dart';
import '../../../../shared/utils/open_url.dart';

class MorePatternsScreen extends ConsumerWidget {
  const MorePatternsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final brand = context.brand;
    final texts = context.texts;
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 600;
    final products = sampleProducts(l10n);
    final freePatterns = ref.watch(freePatternsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: brand.yarnGradient,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(AppRadii.xl),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: Column(
                    children: [
                      Text(l10n.morePatternsTitle, style: texts.headlineMedium),
                      const SizedBox(height: 8),
                      Text(
                        l10n.morePatternsDescription,
                        textAlign: TextAlign.center,
                        style: texts.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.morePatternsFreeTitle, style: texts.titleLarge),
                  const SizedBox(height: 4),
                  Text(l10n.morePatternsFreeDescription),
                ],
              ),
            ),
          ),
          freePatterns.when(
            data: (patterns) => SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridColumns(width),
                  childAspectRatio: 0.58,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) =>
                      _FreePatternCard(pattern: patterns[index]),
                  childCount: patterns.length,
                ),
              ),
            ),
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (error, _) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(l10n.errorOccurred('$error')),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(l10n.morePatternsPaidTitle, style: texts.titleLarge),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridColumns(width),
                childAspectRatio: 0.72,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _ProductCard(product: products[index]),
                childCount: products.length,
              ),
            ),
          ),
          if (isMobile)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 96),
                child: KofiButton(
                  label: l10n.morePatternsVisitKofi,
                  onPressed: () => openUrl(context, l10n.morePatternsKofiUrl),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FreePatternCard extends ConsumerWidget {
  const _FreePatternCard({required this.pattern});

  final FreePattern pattern;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final (title, description) = _localizedPatternText(pattern.id, l10n);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: ColoredBox(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: CustomPaint(
                    size: Size(
                      pattern.project.width.toDouble(),
                      pattern.project.height.toDouble(),
                    ),
                    painter: PatternPainter(project: pattern.project),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  Text(
                    l10n.freePatternAttribution,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(height: 8),
                  FilledButton.tonal(
                    onPressed: () => _addPattern(context, ref, title, l10n),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                    ),
                    child: Text(
                      l10n.freePatternUse,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addPattern(
    BuildContext context,
    WidgetRef ref,
    String title,
    AppLocalizations l10n,
  ) async {
    try {
      await ref
          .read(projectsProvider.notifier)
          .addProject(pattern.createProject(name: title));
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.freePatternAdded)));
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.freePatternAddError('$error'))),
      );
    }
  }
}

(String, String) _localizedPatternText(
  String patternId,
  AppLocalizations l10n,
) => switch (patternId) {
  'blue-guy' => (
    l10n.freePatternBlueGuyTitle,
    l10n.freePatternBlueGuyDescription,
  ),
  _ => (l10n.freePatternButterflyTitle, l10n.freePatternButterflyDescription),
};

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final texts = context.texts;
    final l10n = AppLocalizations.of(context)!;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 4,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(product.imagePath, fit: BoxFit.cover),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: brand.tanSoft,
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                    ),
                    child: Text(
                      l10n.morePatternsPriceBadge,
                      style: texts.labelSmall,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: texts.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Text(
                      product.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: texts.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 10),
                  FilledButton.tonal(
                    onPressed: () => openUrl(context, product.kofiUrl),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                    ),
                    child: Text(l10n.morePatternsVisitKofi),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
