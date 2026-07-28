import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    const colors = AppColors.light;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: colors.brandLavender,
      primary: colors.brandLavender,
      secondary: colors.brandTan,
      tertiary: colors.brandPink,
      surface: colors.brandIvory,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: colors.brandDark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.brandIvory,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: colors.brandLavenderLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(16),
      ),
      extensions: const [colors],
    );
  }

  static ThemeData get dark {
    const colors = AppColors.dark;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: colors.brandLavender,
      brightness: Brightness.dark,
      primary: colors.brandLavender,
      secondary: colors.brandTan,
      tertiary: colors.brandPink,
      surface: colors.brandIvory,
      onPrimary: colors.brandDark,
      onSecondary: colors.brandDark,
      onSurface: colors.brandDark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.brandIvory,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: colors.brandLavenderLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(16),
      ),
      extensions: const [colors],
    );
  }
}
