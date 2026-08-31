import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_crochet/core/theme/app_colors.dart';
import 'package:pixel_crochet/core/theme/app_theme.dart';
import 'package:pixel_crochet/shared/utils/open_url.dart';
import 'package:pixel_crochet/shared/widgets/kofi_button.dart';

import '../../../../generated/app_localizations.dart';

class SupportScreen extends ConsumerWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final brand = context.brand;
    final texts = context.texts;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: brand.pinkSoft,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.favorite_rounded,
                        color: brand.pink,
                        size: 44,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.supportTitle,
                    textAlign: TextAlign.center,
                    style: texts.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.supportDescription,
                    textAlign: TextAlign.center,
                    style: texts.bodyLarge,
                  ),
                  const SizedBox(height: 28),
                  KofiButton(
                    label: l10n.supportDonate,
                    onPressed: () => openUrl(context, l10n.supportKofiUrl),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _MicroCard(
                          icon: Icons.favorite,
                          label: l10n.supportKeepApp,
                          brand: brand,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MicroCard(
                          icon: Icons.auto_awesome,
                          label: l10n.supportNewPatterns,
                          brand: brand,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MicroCard(
                          icon: Icons.share,
                          label: l10n.supportShare,
                          brand: brand,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MicroCard extends StatelessWidget {
  const _MicroCard({
    required this.icon,
    required this.label,
    required this.brand,
  });

  final IconData icon;
  final String label;
  final AppColors brand;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: brand.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Column(
        children: [
          Icon(icon, color: brand.tan),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: context.texts.labelSmall,
          ),
        ],
      ),
    );
  }
}
