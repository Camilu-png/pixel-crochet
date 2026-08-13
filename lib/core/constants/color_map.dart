import 'package:flutter/material.dart';

const Map<String, Color> yarnColors = {
  'black': Color(0xFF2D2D2D),
  'gray': Color(0xFF9E9E9E),
  'white': Color(0xFFF5F5F5),
  'yellow': Color(0xFFFFD54F),
  'red': Color(0xFFE53935),
  'blue': Color(0xFF1E88E5),
  'green': Color(0xFF43A047),
  'brown': Color(0xFF8D6E63),
  'pink': Color(0xFFF06292),
  'purple': Color(0xFF8E24AA),
  'orange': Color(0xFFFB8C00),
  'teal': Color(0xFF00897B),
  'navy': Color(0xFF1565C0),
  'cream': Color(0xFFFFF8E1),
  'coral': Color(0xFFE57373),
  'lavender': Color(0xFF9B8EC4),
  'charcoal': Color(0xFF424242),
  'sky': Color(0xFF64B5F6),
  'mint': Color(0xFF81C784),
  'forest': Color(0xFF2E7D32),
  'maroon': Color(0xFFC62828),
  'burgundy': Color(0xFF880E4F),
  'beige': Color(0xFFF5E6D3),
  'tan': Color(0xFFD4A574),
  'peach': Color(0xFFFFCC80),
  'gold': Color(0xFFF9A825),
  'silver': Color(0xFFBDBDBD),
  'magenta': Color(0xFFE91E63),
  'indigo': Color(0xFF283593),
  'olive': Color(0xFF827717),
  'turquoise': Color(0xFF00BCD4),
  'rose': Color(0xFFF48FB1),
};

Color getYarnColor(String name) {
  if (name.startsWith('#')) {
    final value = int.tryParse(name.substring(1), radix: 16);
    if (value == null) return Colors.grey;
    return Color(0xFF000000 | value);
  }
  return yarnColors[name.toLowerCase()] ?? Colors.grey;
}
