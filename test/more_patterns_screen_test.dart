import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_crochet/core/models/color_block.dart';
import 'package:pixel_crochet/core/models/crochet_project.dart';
import 'package:pixel_crochet/core/models/pattern_row.dart';
import 'package:pixel_crochet/core/models/row_direction.dart';
import 'package:pixel_crochet/core/storage/project_storage_service.dart';
import 'package:pixel_crochet/features/more_patterns/data/free_pattern_catalog.dart';
import 'package:pixel_crochet/features/more_patterns/presentation/more_patterns_screen.dart';
import 'package:pixel_crochet/generated/app_localizations.dart';
import 'support/in_memory_storage.dart';
import 'support/test_theme.dart';

void main() {
  testWidgets('shows free patterns and keeps the current Ko-fi products', (
    tester,
  ) async {
    await tester.pumpWidget(_app(InMemoryStorage({})));
    await tester.pumpAndSettle();

    expect(find.text('Blue Guy'), findsOneWidget);
    expect(find.text('Yellow Butterfly'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Mariposa Cardigan — Size L'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Mariposa Cardigan — Size L'), findsOneWidget);
    expect(find.text('Salchipleto'), findsOneWidget);
  });

  testWidgets('adds a free pattern as a new project with clean progress', (
    tester,
  ) async {
    final storage = InMemoryStorage({});
    await tester.pumpWidget(_app(storage));
    await tester.pumpAndSettle();
    final addButton = find.text('Add to my projects').first;
    await tester.ensureVisible(addButton);
    await tester.pumpAndSettle();
    await tester.tap(addButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final saved = storage.projects.values.single;
    expect(saved.name, 'Blue Guy');
    expect(saved.currentRowIndex, 0);
    expect(saved.completedBlocks, isEmpty);
  });
}

Widget _app(InMemoryStorage storage) {
  return ProviderScope(
    overrides: [
      storageServiceProvider.overrideWithValue(storage),
      freePatternsProvider.overrideWith(
        (ref) async => [_freePattern(), _freePattern(id: 'yellow-butterfly')],
      ),
    ],
    child: MaterialApp(
      theme: testTheme(),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const MorePatternsScreen(),
    ),
  );
}

FreePattern _freePattern({String id = 'blue-guy'}) => FreePattern(
  id: id,
  assetPath: 'test-pattern',
  project: CrochetProject(
    name: 'Source',
    width: 1,
    height: 1,
    rows: const [
      PatternRow(
        rowNumber: 1,
        direction: RowDirection.readLeftToRight,
        colorBlocks: [ColorBlock(colorName: 'blue', count: 1)],
      ),
    ],
  ),
);
