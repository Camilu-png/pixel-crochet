import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_crochet/features/home/presentation/widgets/project_backup_actions.dart';
import 'package:pixel_crochet/generated/app_localizations.dart';

void main() {
  testWidgets('offers export and import actions from the patterns screen', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            appBar: AppBar(actions: const [ProjectBackupActions()]),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Project backup'));
    await tester.pumpAndSettle();

    expect(find.text('Export local backup'), findsOneWidget);
    expect(find.text('Import local backup'), findsOneWidget);
  });
}
