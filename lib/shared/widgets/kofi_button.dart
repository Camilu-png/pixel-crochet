import 'package:flutter/material.dart';
import 'package:pixel_crochet/core/theme/context_extensions.dart';

class KofiButton extends StatelessWidget {
  const KofiButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.bolt),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: context.colors.brandLavender,
        foregroundColor: Colors.white,
        shape: const StadiumBorder(),
        textStyle: context.text.titleMedium,
      ),
    );
  }
}
