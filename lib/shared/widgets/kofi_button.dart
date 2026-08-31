import 'package:flutter/material.dart';
import 'package:pixel_crochet/core/theme/app_colors.dart';

class KofiButton extends StatelessWidget {
  const KofiButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.local_cafe_rounded),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: context.brand.pink,
        foregroundColor: context.brand.ink,
        minimumSize: const Size.fromHeight(56),
      ),
    );
  }
}
