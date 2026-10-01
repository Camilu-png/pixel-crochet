import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_crochet/core/models/color_block.dart';
import 'package:pixel_crochet/core/models/crochet_project.dart';
import 'package:pixel_crochet/core/models/pattern_row.dart';
import 'package:pixel_crochet/core/models/row_direction.dart';
import 'package:pixel_crochet/core/storage/project_storage_service.dart';
import 'package:pixel_crochet/core/theme/app_theme.dart';
import 'package:pixel_crochet/features/project/presentation/project_screen.dart';
import 'package:pixel_crochet/generated/app_localizations.dart';
import 'support/in_memory_storage.dart';

void main() {
  late Map<String, CrochetProject> projects;
  late String projectId;

  setUp(() {
    final project = CrochetProject(
      name: 'Test Project',
      width: 3,
      height: 2,
      rows: [
        PatternRow(
          rowNumber: 1,
          direction: RowDirection.readLeftToRight,
          colorBlocks: [ColorBlock(colorName: 'black', count: 3)],
        ),
        PatternRow(
          rowNumber: 2,
          direction: RowDirection.readRightToLeft,
          colorBlocks: [ColorBlock(colorName: 'white', count: 3)],
        ),
      ],
    );
    projectId = project.id;
    projects = {project.id: project};
  });

  Widget buildScreen() => MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en'), Locale('es')],
    theme: AppTheme.light(),
    home: ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(InMemoryStorage(projects)),
      ],
      child: ProjectScreen(projectId: projectId),
    ),
  );

  testWidgets('renders the current row and persists row navigation', (
    tester,
  ) async {
    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    expect(find.textContaining('Row 1/2'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Row 2/2'), findsOneWidget);
    expect(projects[projectId]!.currentRowIndex, 1);
  });

  testWidgets('toggling a block persists completion', (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    await tester.tap(find.text('3 black'));
    await tester.pumpAndSettle();

    expect(projects[projectId]!.isBlockCompleted(0, 0), isTrue);
  });

  testWidgets('swaps a reverse-side row whenever double knitting is on', (
    tester,
  ) async {
    projects[projectId] = projects[projectId]!.copyWith(doubleKnitting: true);

    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    // Row 1 reads left to right, so it is worked on the reverse side of the
    // fabric: its blocks show the two yarns actually being swapped.
    expect(find.text('3 white'), findsOneWidget);
    expect(find.text('3 black'), findsNothing);
  });

  testWidgets('leaves a right-side row in the pattern colors', (tester) async {
    projects[projectId] = projects[projectId]!.copyWith(
      doubleKnitting: true,
      currentRowIndex: 1,
    );

    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    // Row 2 reads right to left, the front of the fabric: the blocks keep the
    // colors the pattern stores.
    expect(find.text('3 white'), findsOneWidget);
    expect(find.text('3 black'), findsNothing);
  });

  testWidgets('has no view toggle: the chart follows the row', (tester) async {
    projects[projectId] = projects[projectId]!.copyWith(doubleKnitting: true);

    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    expect(find.byTooltip('Double knitting colors'), findsNothing);
  });

  testWidgets('keeps double knitting unavailable for a three color pattern', (
    tester,
  ) async {
    projects[projectId] = CrochetProject(
      name: 'Three',
      width: 3,
      height: 1,
      rows: const [
        PatternRow(
          rowNumber: 1,
          direction: RowDirection.readLeftToRight,
          colorBlocks: [
            ColorBlock(colorName: 'black', count: 1),
            ColorBlock(colorName: 'white', count: 1),
            ColorBlock(colorName: 'red', count: 1),
          ],
        ),
      ],
    );

    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();

    final toggle = tester.widget<SwitchListTile>(find.byType(SwitchListTile));
    expect(toggle.onChanged, isNull);
    expect(find.textContaining('exactly 2 colors'), findsOneWidget);
  });

  testWidgets('enables double knitting from the edit sheet', (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(projects[projectId]!.doubleKnitting, isTrue);
  });

  testWidgets('turns double knitting off when the colors are merged', (
    tester,
  ) async {
    projects[projectId] = projects[projectId]!.copyWith(doubleKnitting: true);

    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Change').first);
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('white'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(projects[projectId]!.doubleKnitting, isFalse);
    expect(
      find.textContaining('no longer has exactly 2 colors'),
      findsOneWidget,
    );
  });
}
