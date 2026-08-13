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

class _InMemoryStorage extends ProjectStorageService {
  _InMemoryStorage(Map<String, CrochetProject> projects) : _projects = projects;

  final Map<String, CrochetProject> _projects;

  @override
  Future<CrochetProject?> load(String id) async => _projects[id];

  @override
  Future<void> save(CrochetProject project) async {
    _projects[project.id] = project;
  }
}

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
        theme: AppTheme.light,
        home: ProviderScope(
          overrides: [
            storageServiceProvider
                .overrideWithValue(_InMemoryStorage(projects)),
          ],
          child: ProjectScreen(projectId: projectId),
        ),
      );

  testWidgets('renders the current row and persists row navigation',
      (tester) async {
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
}
