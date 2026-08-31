import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_crochet/core/constants/products.dart';
import 'package:pixel_crochet/shared/widgets/kofi_button.dart';

import '../../../../generated/app_localizations.dart';
import '../../../../core/theme/context_extensions.dart';
import '../../../../shared/utils/open_url.dart';

class MorePatternsScreen extends ConsumerWidget {
  const MorePatternsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              Text(
                l10n.morePatternsTitle,
                style: context.text.headlineMedium?.copyWith(
                  color: context.colors.brandDark,
                ),
              ),
              Text(
                l10n.morePatternsDescription,
                style: context.text.bodyLarge?.copyWith(
                  color: context.colors.brandDark.withValues(alpha: 0.6),
                ),
              ),
              Text(
                l10n.morePatternsHowToUpload,
                style: context.text.bodyLarge?.copyWith(
                  color: context.colors.brandDark.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _getColumns(context),
            childAspectRatio: 0.85,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => _ProductCard(product: sampleProducts[index]),
            childCount: sampleProducts.length,
          ),
        ),
        SliverToBoxAdapter(
          child: KofiButton(
            label: l10n.morePatternsVisitKofi,
            onPressed: () => openUrl(context, l10n.morePatternsKofiUrl),
          ),
        ),
      ],
    );
  }
}

int _getColumns(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width < 600) return 2;
  if (width < 900) return 3;
  return 4;
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => openUrl(context, product.kofiUrl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: Image.asset(product.imagePath, fit: BoxFit.cover)),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                product.title,
                style: context.text.titleMedium?.copyWith(
                  color: context.colors.brandDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text(
                product.description,
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.brandDark.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
