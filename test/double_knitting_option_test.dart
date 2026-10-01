import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_crochet/core/theme/app_theme.dart';
import 'package:pixel_crochet/generated/app_localizations.dart';
import 'package:pixel_crochet/shared/widgets/double_knitting_option.dart';

void main() {
  Widget app({
    required int colorCount,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return MaterialApp(
      theme: AppTheme.light(),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('es')],
      home: Scaffold(
        body: DoubleKnittingOption(
          colorCount: colorCount,
          value: value,
          onChanged: onChanged,
        ),
      ),
    );
  }

  testWidgets('is switchable for a two color pattern', (tester) async {
    bool? chosen;
    await tester.pumpWidget(
      app(colorCount: 2, value: false, onChanged: (v) => chosen = v),
    );

    expect(find.text('Double knitting'), findsOneWidget);
    expect(find.textContaining('exactly 2 colors'), findsNothing);

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    expect(chosen, isTrue);
  });

  testWidgets('is disabled with an explanation for other color counts', (
    tester,
  ) async {
    bool? chosen;
    await tester.pumpWidget(
      app(colorCount: 3, value: false, onChanged: (v) => chosen = v),
    );

    final tile = tester.widget<SwitchListTile>(find.byType(SwitchListTile));
    expect(tile.onChanged, isNull);
    expect(find.textContaining('exactly 2 colors'), findsOneWidget);

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    expect(chosen, isNull, reason: 'a disabled switch must not report');
  });
}
