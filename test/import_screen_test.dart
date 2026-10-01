import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_crochet/core/models/crochet_project.dart';
import 'package:pixel_crochet/core/onboarding/onboarding_provider.dart';
import 'package:pixel_crochet/core/storage/project_storage_service.dart';
import 'package:pixel_crochet/features/import_pattern/presentation/import_screen.dart';
import 'package:pixel_crochet/generated/app_localizations.dart';

import 'support/in_memory_storage.dart';
import 'support/seen_onboarding.dart';
import 'support/test_theme.dart';

const _twoColorPattern =
    'Muestra\n6 x 2\n'
    'Row 1 <-: 3 black, 3 white\n'
    'Row 2 ->: 3 white, 3 black\n';

const _threeColorPattern =
    'Muestra\n6 x 2\n'
    'Row 1 <-: 2 black, 2 white, 2 red\n'
    'Row 2 ->: 2 white, 2 red, 2 black\n';

void main() {
  late Map<String, CrochetProject> projects;

  setUp(() => projects = {});

  Widget app() {
    final router = GoRouter(
      initialLocation: '/import',
      routes: [
        GoRoute(path: '/', name: 'home', builder: (_, _) => const SizedBox()),
        GoRoute(
          path: '/import',
          name: 'import',
          builder: (_, _) => const ImportScreen(),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(InMemoryStorage(projects)),
        onboardingStorageProvider.overrideWithValue(SeenOnboarding()),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        theme: testTheme(),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('es')],
      ),
    );
  }

  /// Scrolls a control into view first: the action buttons sit below the fold
  /// on the default 800x600 test surface. Deliberately leaves the tap pending —
  /// callers settle themselves, because a settled frame never comes while the
  /// import spinner is running.
  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
  }

  /// Gives the parser's isolate real time to finish; `compute` cannot resolve
  /// on the fake clock `testWidgets` runs on.
  Future<void> letParseFinish(WidgetTester tester) async {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(seconds: 2)),
    );
    await tester.pumpAndSettle();
  }

  Future<void> pasteAndParse(WidgetTester tester, String pattern) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), pattern);
    await tapVisible(
      tester,
      find.widgetWithText(FilledButton, 'Import Pattern'),
    );
    await letParseFinish(tester);
  }

  testWidgets('keeps double knitting disabled for a three color pattern', (
    tester,
  ) async {
    await pasteAndParse(tester, _threeColorPattern);

    final tile = tester.widget<SwitchListTile>(find.byType(SwitchListTile));
    expect(tile.onChanged, isNull);
    expect(find.textContaining('exactly 2 colors'), findsOneWidget);
  });

  testWidgets('creates the project with double knitting when it is switched', (
    tester,
  ) async {
    await pasteAndParse(tester, _twoColorPattern);

    await tapVisible(tester, find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    final toggled = tester.widget<SwitchListTile>(find.byType(SwitchListTile));
    expect(toggled.value, isTrue, reason: 'the switch must reflect the tap');

    await tapVisible(
      tester,
      find.widgetWithText(FilledButton, 'Import Pattern'),
    );
    await letParseFinish(tester);

    expect(projects, hasLength(1));
    expect(projects.values.single.doubleKnitting, isTrue);
    expect(projects.values.single.invertedView, isFalse);
  });
}

/// Onboarding that has already been shown, so the tutorial overlay never
/// covers the controls under test.
