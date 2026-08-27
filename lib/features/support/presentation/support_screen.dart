import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_crochet/core/theme/context_extensions.dart';
import 'package:pixel_crochet/shared/utils/open_url.dart';

import '../../../../generated/app_localizations.dart';

class SupportScreen extends ConsumerWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.supportTitle,
              textAlign: TextAlign.center,
              style: context.text.headlineMedium?.copyWith(
                color: context.colors.brandDark,
              ),
            ),
            SizedBox(height: 16),
            Text(
              l10n.supportDescription,
              textAlign: TextAlign.center,
              style: context.text.bodyLarge?.copyWith(
                color: context.colors.brandDark.withValues(alpha: 0.6),
              ),
            ),
            SizedBox(height: 32),
            FilledButton(
              onPressed: () => openUrl(context, l10n.supportKofiUrl),
              child: Text(l10n.supportDonate),
            ),
          ],
        ),
      ),
    );
  }
}
