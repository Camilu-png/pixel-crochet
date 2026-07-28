import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pixel_crochet/app.dart';
import 'package:pixel_crochet/generated/app_localizations.dart';

void main() {
  testWidgets('PixelApp builds without errors', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('es')],
        home: const ProviderScope(child: PixelApp()),
      ),
    );

    expect(find.byType(MaterialApp), findsWidgets);
  });
}
