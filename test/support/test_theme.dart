import 'package:flutter/material.dart';

import 'package:pixel_crochet/core/theme/app_colors.dart';

/// A theme carrying the app's real color extension but Flutter's default
/// typography.
///
/// Tests that need [WidgetTester.runAsync] cannot use `AppTheme.light()`: its
/// GoogleFonts styles trigger a runtime download that never resolves inside
/// `testWidgets`' fake clock, and the fonts it requests currently 404, so the
/// deferred failure surfaces as an error once real async is allowed to run.
/// Every assertion these tests make is about state and copy, not typography.
ThemeData testTheme() =>
    ThemeData(useMaterial3: true, extensions: const [AppColors.light]);
