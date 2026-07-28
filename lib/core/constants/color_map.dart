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
};

Color getYarnColor(String name) {
  return yarnColors[name.toLowerCase()] ?? Colors.transparent;
}
