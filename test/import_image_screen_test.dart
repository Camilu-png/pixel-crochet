import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;
import 'package:pixel_crochet/core/models/crochet_project.dart';
import 'package:pixel_crochet/core/onboarding/onboarding_provider.dart';
import 'package:pixel_crochet/core/storage/project_storage_service.dart';
import 'package:pixel_crochet/features/import_image/presentation/import_image_screen.dart';
import 'package:pixel_crochet/generated/app_localizations.dart';

import 'support/in_memory_storage.dart';
import 'support/seen_onboarding.dart';
import 'support/test_theme.dart';

/// Exact yarn colours from `yarnColors`, so the nearest-yarn lookup lands on
/// the name rather than on a neighbour.
const _dark = Color(0xFF2D2D2D);
const _light = Color(0xFFF5F5F5);
const _accent = Color(0xFFE53935);

/// A 6 x 2 stitch chart at 30 pixels per stitch, which is what the screen
/// suggests for an image this size.
Uint8List _chartPng({required bool threeColor}) {
  const cell = 30;
  final image = img.Image(width: cell * 6, height: cell * 2);

  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      final col = x ~/ cell;
      final row = y ~/ cell;
      final color = threeColor
          ? [_dark, _light, _accent][(row * 3 + col) % 3]
          : (row == 0
                ? (col < 3 ? _dark : _light)
                : (col < 3 ? _light : _dark));
      final argb = color.toARGB32();
      image.setPixel(
        x,
        y,
        img.ColorRgb8((argb >> 16) & 0xFF, (argb >> 8) & 0xFF, argb & 0xFF),
      );
    }
  }

  return img.encodePng(image);
}

class _FakeFilePicker extends FilePicker {
  _FakeFilePicker(this._png);

  final Uint8List _png;

  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    bool allowCompression = true,
    int compressionQuality = 30,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
  }) async {
    return FilePickerResult([
      PlatformFile(name: 'muestra.png', size: _png.length, bytes: _png),
    ]);
  }
}

void main() {
  late Map<String, CrochetProject> projects;

  setUp(() {
    projects = {};
    FilePicker.platform = _FakeFilePicker(_chartPng(threeColor: false));
  });

  Widget screen(Uint8List png) {
    FilePicker.platform = _FakeFilePicker(png);
    final router = GoRouter(
      initialLocation: '/image-import',
      routes: [
        GoRoute(path: '/', name: 'home', builder: (_, _) => const SizedBox()),
        GoRoute(
          path: '/image-import',
          name: 'image-import',
          builder: (_, _) => const ImportImageScreen(),
        ),
        GoRoute(
          path: '/project/:id',
          name: 'project',
          builder: (_, _) => const SizedBox(),
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

  /// Scrolls the control into view, taps it, and then gives the real isolate
  /// work — decoding the file and building the grid — time to finish before
  /// settling. An indeterminate spinner runs while that work is in flight, so
  /// settling must not start first.
  Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(seconds: 2)),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openChart(
    WidgetTester tester, {
    required bool threeColor,
  }) async {
    await tester.pumpWidget(screen(_chartPng(threeColor: threeColor)));
    await tester.pumpAndSettle();

    await tapAndSettle(
      tester,
      find.widgetWithText(FilledButton, 'Select Image'),
    );
    await tapAndSettle(
      tester,
      find.widgetWithText(FilledButton, 'Preview Pattern'),
    );
  }

  testWidgets('saves a two color image with double knitting on', (
    tester,
  ) async {
    await openChart(tester, threeColor: false);

    final tile = tester.widget<SwitchListTile>(find.byType(SwitchListTile));
    expect(tile.onChanged, isNotNull);
    expect(find.textContaining('exactly 2 colors'), findsNothing);

    await tester.ensureVisible(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    await tapAndSettle(
      tester,
      find.widgetWithText(FilledButton, 'Import Pattern'),
    );

    expect(projects, hasLength(1));
    expect(projects.values.single.doubleKnitting, isTrue);
  });

  testWidgets('keeps double knitting disabled for a three color image', (
    tester,
  ) async {
    await openChart(tester, threeColor: true);

    final tile = tester.widget<SwitchListTile>(find.byType(SwitchListTile));
    expect(tile.onChanged, isNull);
    expect(find.textContaining('exactly 2 colors'), findsOneWidget);
  });

  testWidgets('unlocks double knitting once the chart is recolored to two', (
    tester,
  ) async {
    await openChart(tester, threeColor: true);

    final changeButtons = find.widgetWithText(TextButton, 'Change');
    expect(changeButtons, findsNWidgets(3));

    // The palette is sorted darkest first, so the middle swatch is the accent
    // color; folding it into a color the chart already uses leaves two.
    await tester.ensureVisible(changeButtons.at(1));
    await tester.pumpAndSettle();
    await tester.tap(changeButtons.at(1));
    await tester.pumpAndSettle();

    // The dialog lists every yarn and the palette, so the name repeats.
    await tester.tap(
      find
          .descendant(
            of: find.byType(AlertDialog),
            matching: find.text('black'),
          )
          .first,
    );
    await tester.pumpAndSettle();

    final tile = tester.widget<SwitchListTile>(find.byType(SwitchListTile));
    expect(
      tile.onChanged,
      isNotNull,
      reason: 'reducing the chart to two colors must unlock the option',
    );

    await tester.ensureVisible(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    await tapAndSettle(
      tester,
      find.widgetWithText(FilledButton, 'Import Pattern'),
    );

    expect(projects, hasLength(1));
    expect(projects.values.single.doubleKnitting, isTrue);
  });
}
