import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.ivory,
    required this.surface,
    required this.surfaceAlt,
    required this.lavender,
    required this.lavenderSoft,
    required this.tan,
    required this.tanSoft,
    required this.pink,
    required this.pinkSoft,
    required this.ink,
    required this.inkMuted,
    required this.outlineSoft,
    required this.success,
    required this.danger,
    required this.yarnGradient,
    required this.progressGradient,
    required this.softShadow,
  });

  final Color ivory;
  final Color surface;
  final Color surfaceAlt;
  final Color lavender;
  final Color lavenderSoft;
  final Color tan;
  final Color tanSoft;
  final Color pink;
  final Color pinkSoft;
  final Color ink;
  final Color inkMuted;
  final Color outlineSoft;
  final Color success;
  final Color danger;
  final LinearGradient yarnGradient;
  final LinearGradient progressGradient;
  final List<BoxShadow> softShadow;

  // Legacy aliases so existing screens (import/visor) keep working.
  Color get brandIvory => ivory;
  Color get brandSurface => surface;
  Color get brandSurfaceAlt => surfaceAlt;
  Color get brandLavender => lavender;
  Color get brandLavenderLight => lavenderSoft;
  Color get brandTan => tan;
  Color get brandTanLight => tanSoft;
  Color get brandPink => pink;
  Color get brandDark => ink;

  static const light = AppColors(
    ivory: Color(0xFFFFF9F2),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFF7EFE6),
    lavender: Color(0xFF7B6BB0),
    lavenderSoft: Color(0xFFC8BFE7),
    tan: Color(0xFFC08A4E),
    tanSoft: Color(0xFFF3E3D0),
    pink: Color(0xFFE3798E),
    pinkSoft: Color(0xFFFDE4E9),
    ink: Color(0xFF241F2B),
    inkMuted: Color(0xFF6B6377),
    outlineSoft: Color(0xFFE7DACB),
    success: Color(0xFF5E8C61),
    danger: Color(0xFFB3453F),
    yarnGradient: LinearGradient(
      colors: [Color(0xFFC8BFE7), Color(0xFFF3E3D0)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    progressGradient: LinearGradient(
      colors: [Color(0xFF7B6BB0), Color(0xFFE3798E)],
    ),
    softShadow: [
      BoxShadow(
        color: Color(0x147B6BB0),
        blurRadius: 24,
        offset: Offset(0, 8),
      ),
    ],
  );

  static const dark = AppColors(
    ivory: Color(0xFF17141F),
    surface: Color(0xFF1E1A2A),
    surfaceAlt: Color(0xFF252036),
    lavender: Color(0xFFC3B8EA),
    lavenderSoft: Color(0xFF3D3654),
    tan: Color(0xFFE8C79A),
    tanSoft: Color(0xFF2E2620),
    pink: Color(0xFFF4B3C1),
    pinkSoft: Color(0xFF3A2630),
    ink: Color(0xFFF3EFEA),
    inkMuted: Color(0xFFB6AEC2),
    outlineSoft: Color(0xFF3A3348),
    success: Color(0xFF9BC79E),
    danger: Color(0xFFF0918B),
    yarnGradient: LinearGradient(
      colors: [Color(0xFF3D3654), Color(0xFF2E2620)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    progressGradient: LinearGradient(
      colors: [Color(0xFFC3B8EA), Color(0xFFF4B3C1)],
    ),
    softShadow: [
      BoxShadow(
        color: Color(0x66000000),
        blurRadius: 28,
        offset: Offset(0, 10),
      ),
    ],
  );

  @override
  AppColors copyWith({
    Color? ivory,
    Color? surface,
    Color? surfaceAlt,
    Color? lavender,
    Color? lavenderSoft,
    Color? tan,
    Color? tanSoft,
    Color? pink,
    Color? pinkSoft,
    Color? ink,
    Color? inkMuted,
    Color? outlineSoft,
    Color? success,
    Color? danger,
    LinearGradient? yarnGradient,
    LinearGradient? progressGradient,
    List<BoxShadow>? softShadow,
  }) {
    return AppColors(
      ivory: ivory ?? this.ivory,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      lavender: lavender ?? this.lavender,
      lavenderSoft: lavenderSoft ?? this.lavenderSoft,
      tan: tan ?? this.tan,
      tanSoft: tanSoft ?? this.tanSoft,
      pink: pink ?? this.pink,
      pinkSoft: pinkSoft ?? this.pinkSoft,
      ink: ink ?? this.ink,
      inkMuted: inkMuted ?? this.inkMuted,
      outlineSoft: outlineSoft ?? this.outlineSoft,
      success: success ?? this.success,
      danger: danger ?? this.danger,
      yarnGradient: yarnGradient ?? this.yarnGradient,
      progressGradient: progressGradient ?? this.progressGradient,
      softShadow: softShadow ?? this.softShadow,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      ivory: Color.lerp(ivory, other.ivory, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      lavender: Color.lerp(lavender, other.lavender, t)!,
      lavenderSoft: Color.lerp(lavenderSoft, other.lavenderSoft, t)!,
      tan: Color.lerp(tan, other.tan, t)!,
      tanSoft: Color.lerp(tanSoft, other.tanSoft, t)!,
      pink: Color.lerp(pink, other.pink, t)!,
      pinkSoft: Color.lerp(pinkSoft, other.pinkSoft, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkMuted: Color.lerp(inkMuted, other.inkMuted, t)!,
      outlineSoft: Color.lerp(outlineSoft, other.outlineSoft, t)!,
      success: Color.lerp(success, other.success, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      yarnGradient: LinearGradient.lerp(yarnGradient, other.yarnGradient, t)!,
      progressGradient:
          LinearGradient.lerp(progressGradient, other.progressGradient, t)!,
      softShadow: BoxShadow.lerpList(softShadow, other.softShadow, t)!,
    );
  }
}

extension AppColorsX on BuildContext {
  AppColors get brand => Theme.of(this).extension<AppColors>()!;
  AppColors get colors => brand;
  ColorScheme get scheme => Theme.of(this).colorScheme;
  TextTheme get texts => Theme.of(this).textTheme;
  TextTheme get text => Theme.of(this).textTheme;
}
