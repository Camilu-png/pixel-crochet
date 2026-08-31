import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppRadii {
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 20.0;
  static const xl = 28.0;
}

class AppTheme {
  static ThemeData light() => _build(Brightness.light, AppColors.light);
  static ThemeData dark() => _build(Brightness.dark, AppColors.dark);

  static ThemeData _build(Brightness brightness, AppColors brand) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF7B6BB0),
      brightness: brightness,
    ).copyWith(
      primary: brand.lavender,
      onPrimary: brightness == Brightness.light
          ? const Color(0xFFFFFFFF)
          : const Color(0xFF241F2B),
      primaryContainer: brand.lavenderSoft,
      onPrimaryContainer: brand.ink,
      secondary: brand.tan,
      secondaryContainer: brand.tanSoft,
      onSecondaryContainer: brand.ink,
      tertiary: brand.pink,
      tertiaryContainer: brand.pinkSoft,
      onTertiaryContainer: brand.ink,
      surface: brand.surface,
      onSurface: brand.ink,
      onSurfaceVariant: brand.inkMuted,
      surfaceContainerLowest: brand.ivory,
      surfaceContainerLow: brand.surfaceAlt,
      surfaceContainer: brand.surfaceAlt,
      surfaceContainerHigh: brand.surfaceAlt,
      outline: brand.outlineSoft,
      outlineVariant: brand.outlineSoft,
      error: brand.danger,
      onError: brightness == Brightness.light
          ? const Color(0xFFFFFFFF)
          : const Color(0xFF241F2B),
    );

    final base = ThemeData(useMaterial3: true, colorScheme: scheme);

    final textTheme = GoogleFonts.nunitoTextTheme(base.textTheme)
        .apply(bodyColor: brand.ink, displayColor: brand.ink)
        .copyWith(
          displaySmall: GoogleFonts.fraunces(
            fontSize: 34,
            height: 1.18,
            fontWeight: FontWeight.w700,
            color: brand.ink,
          ),
          headlineMedium: GoogleFonts.fraunces(
            fontSize: 26,
            height: 1.23,
            fontWeight: FontWeight.w600,
            color: brand.ink,
          ),
          titleLarge: GoogleFonts.fraunces(
            fontSize: 20,
            height: 1.3,
            fontWeight: FontWeight.w600,
            color: brand.ink,
          ),
          titleMedium: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: brand.ink,
          ),
          bodyLarge: GoogleFonts.nunito(
            fontSize: 16,
            height: 1.5,
            color: brand.ink,
          ),
          bodyMedium: GoogleFonts.nunito(
            fontSize: 14,
            height: 1.5,
            color: brand.inkMuted,
          ),
          labelLarge: GoogleFonts.nunito(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          labelSmall: GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: .4,
            color: brand.inkMuted,
          ),
        );

    return base.copyWith(
      scaffoldBackgroundColor: brand.ivory,
      textTheme: textTheme,
      extensions: [brand],
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: brand.ivory,
        surfaceTintColor: Colors.transparent,
        foregroundColor: brand.ink,
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          side: BorderSide(color: brand.outlineSoft),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.xl),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: brand.lavender,
          textStyle: textTheme.labelLarge,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: brand.lavender,
        foregroundColor: scheme.onPrimary,
        elevation: 2,
        highlightElevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: brand.tanSoft,
        side: BorderSide.none,
        labelStyle: textTheme.labelSmall,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brand.surfaceAlt,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        hintStyle: textTheme.bodyMedium,
        labelStyle: textTheme.bodyMedium,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: brand.outlineSoft),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: brand.lavender, width: 2),
        ),
      ),
      navigationDrawerTheme: NavigationDrawerThemeData(
        backgroundColor: brand.surfaceAlt,
        surfaceTintColor: Colors.transparent,
        indicatorColor: brand.lavenderSoft,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? textTheme.titleMedium
              : textTheme.bodyLarge,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.xl),
        ),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyLarge,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: brand.lavenderSoft,
        contentTextStyle: textTheme.bodyLarge?.copyWith(color: brand.ink),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: brand.outlineSoft,
        space: 1,
        thickness: 1,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: brand.lavender,
        linearTrackColor: brand.lavenderSoft,
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: brand.lavender,
          side: BorderSide(color: brand.outlineSoft),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.lg),
          ),
        ),
      ),
    );
  }
}
