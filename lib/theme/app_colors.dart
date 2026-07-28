import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.brandIvory,
    required this.brandLavender,
    required this.brandLavenderLight,
    required this.brandTan,
    required this.brandTanLight,
    required this.brandPink,
    required this.brandDark,
  });

  final Color brandIvory;
  final Color brandLavender;
  final Color brandLavenderLight;
  final Color brandTan;
  final Color brandTanLight;
  final Color brandPink;
  final Color brandDark;

  static const light = AppColors(
    brandIvory: Color(0xFFFFF8F0),
    brandLavender: Color(0xFF9B8EC4),
    brandLavenderLight: Color(0xFFC8BFE7),
    brandTan: Color(0xFFD4A574),
    brandTanLight: Color(0xFFF0DCC8),
    brandPink: Color(0xFFF5A0B0),
    brandDark: Color(0xFF2D2D2D),
  );

  static const dark = AppColors(
    brandIvory: Color(0xFF1E1E2E),
    brandLavender: Color(0xFFB8AEE0),
    brandLavenderLight: Color(0xFF3D3654),
    brandTan: Color(0xFFE0B88A),
    brandTanLight: Color(0xFF2E2620),
    brandPink: Color(0xFFF0B8C4),
    brandDark: Color(0xFFF0F0F0),
  );

  @override
  AppColors copyWith({
    Color? brandIvory,
    Color? brandLavender,
    Color? brandLavenderLight,
    Color? brandTan,
    Color? brandTanLight,
    Color? brandPink,
    Color? brandDark,
  }) {
    return AppColors(
      brandIvory: brandIvory ?? this.brandIvory,
      brandLavender: brandLavender ?? this.brandLavender,
      brandLavenderLight: brandLavenderLight ?? this.brandLavenderLight,
      brandTan: brandTan ?? this.brandTan,
      brandTanLight: brandTanLight ?? this.brandTanLight,
      brandPink: brandPink ?? this.brandPink,
      brandDark: brandDark ?? this.brandDark,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      brandIvory: Color.lerp(brandIvory, other.brandIvory, t)!,
      brandLavender: Color.lerp(brandLavender, other.brandLavender, t)!,
      brandLavenderLight:
          Color.lerp(brandLavenderLight, other.brandLavenderLight, t)!,
      brandTan: Color.lerp(brandTan, other.brandTan, t)!,
      brandTanLight: Color.lerp(brandTanLight, other.brandTanLight, t)!,
      brandPink: Color.lerp(brandPink, other.brandPink, t)!,
      brandDark: Color.lerp(brandDark, other.brandDark, t)!,
    );
  }
}
