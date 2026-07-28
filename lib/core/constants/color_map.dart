import 'package:flutter/material.dart';

const Map<String, Color> yarnColors = {
  'black': Color(0xFF2D2D2D),
  'gray': Color(0xFF9E9E9E),
  'white': Color(0xFFF5F5F5),
  'yellow': Color(0xFFFFD54F),
};

Color getYarnColor(String name) {
  return yarnColors[name.toLowerCase()] ?? Colors.transparent;
}
