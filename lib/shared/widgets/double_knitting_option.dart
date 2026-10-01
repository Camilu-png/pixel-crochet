import 'package:flutter/material.dart';

import '../../core/theme/context_extensions.dart';
import '../../generated/app_localizations.dart';

/// The double knitting switch shown wherever a pattern is created or edited.
///
/// It is always visible so the option can be discovered, but it only switches
/// when the pattern uses exactly two colors: [colorCount] decides that, and an
/// ineligible count disables the switch with an explanation instead of hiding
/// the option.
class DoubleKnittingOption extends StatelessWidget {
  const DoubleKnittingOption({
    super.key,
    required this.colorCount,
    required this.value,
    required this.onChanged,
  });

  final int colorCount;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final eligible = colorCount == 2;

    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        l10n.doubleKnitting,
        style: context.text.titleMedium?.copyWith(
          color: context.colors.brandDark,
        ),
      ),
      subtitle: eligible
          ? null
          : Text(
              l10n.doubleKnittingRequiresTwoColors,
              style: context.text.bodySmall?.copyWith(
                color: context.colors.brandDark.withValues(alpha: 0.6),
              ),
            ),
      value: eligible && value,
      onChanged: eligible ? onChanged : null,
    );
  }
}
