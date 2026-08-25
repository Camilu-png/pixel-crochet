import 'package:flutter/material.dart';

@immutable
class ColorBlock {
  const ColorBlock({required this.colorName, required this.count});

  final String colorName;
  final int count;

  Map<String, dynamic> toJson() => {'colorName': colorName, 'count': count};

  factory ColorBlock.fromJson(Map<String, dynamic> json) {
    return ColorBlock(
      colorName: json['colorName'] as String,
      count: json['count'] as int,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ColorBlock &&
          runtimeType == other.runtimeType &&
          colorName == other.colorName &&
          count == other.count;

  @override
  int get hashCode => Object.hash(colorName, count);
}
