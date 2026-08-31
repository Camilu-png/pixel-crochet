import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_crochet/core/constants/products.dart';
import 'package:pixel_crochet/core/theme/app_colors.dart';
import 'package:pixel_crochet/core/theme/app_theme.dart';
import 'package:pixel_crochet/shared/widgets/kofi_button.dart';

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
                      Text(
                        l10n.morePatternsTitle,
                        style: texts.headlineMedium,
                      ),
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
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _columnsFor(width),
                childAspectRatio: 0.72,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) =>
                    _ProductCard(product: sampleProducts[index]),
                childCount: sampleProducts.length,
              ),
            ),
          ),
          if (isMobile)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 96),
                child: KofiButton(
                  label: l10n.morePatternsVisitKofi,
                  onPressed: () =>
                      openUrl(context, l10n.morePatternsKofiUrl),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

int _columnsFor(double width) {
  if (width >= 1200) return 4;
  if (width >= 900) return 3;
  if (width >= 600) return 3;
  return 2;
}

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
