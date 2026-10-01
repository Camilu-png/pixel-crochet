import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_crochet/core/models/color_block.dart';
import 'package:pixel_crochet/core/models/crochet_project.dart';
import 'package:pixel_crochet/core/models/pattern_row.dart';
import 'package:pixel_crochet/core/models/row_direction.dart';
import 'package:pixel_crochet/core/theme/app_theme.dart';
import 'package:pixel_crochet/features/home/presentation/widgets/project_card.dart';
import 'package:pixel_crochet/generated/app_localizations.dart';

void main() {
  CrochetProject project({bool doubleKnitting = false}) {
    return CrochetProject(
      name: 'Muestra',
      width: 6,
      height: 2,
      doubleKnitting: doubleKnitting,
      rows: const [
        PatternRow(
          rowNumber: 1,
          direction: RowDirection.readLeftToRight,
          colorBlocks: [
            ColorBlock(colorName: 'negro', count: 3),
            ColorBlock(colorName: 'blanco', count: 3),
          ],
        ),
        PatternRow(
          rowNumber: 2,
          direction: RowDirection.readRightToLeft,
          colorBlocks: [
            ColorBlock(colorName: 'blanco', count: 3),
            ColorBlock(colorName: 'negro', count: 3),
          ],
        ),
      ],
    );
  }

  Widget card(CrochetProject project) => MaterialApp(
    theme: AppTheme.light(),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en'), Locale('es')],
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 320,
          child: ProjectCard(project: project, onTap: () {}, onDelete: () {}),
        ),
      ),
    ),
  );

  testWidgets('labels a double knitting project', (tester) async {
    await tester.pumpWidget(card(project(doubleKnitting: true)));
    await tester.pumpAndSettle();

    expect(find.text('Double knitting'), findsOneWidget);
  });

  testWidgets('leaves the label off a regular project', (tester) async {
    await tester.pumpWidget(card(project()));
    await tester.pumpAndSettle();

    expect(find.text('Double knitting'), findsNothing);
  });
}
