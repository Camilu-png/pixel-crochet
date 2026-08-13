import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_crochet/core/models/color_block.dart';
import 'package:pixel_crochet/core/models/crochet_project.dart';
import 'package:pixel_crochet/core/models/pattern_row.dart';
import 'package:pixel_crochet/core/models/row_direction.dart';
import 'package:pixel_crochet/core/storage/project_storage_service.dart';
import 'package:pixel_crochet/features/home/providers/home_provider.dart';
import 'package:pixel_crochet/features/project/providers/project_provider.dart';

void main() {
  late Directory tempDir;
  late ProjectStorageService storage;
  late ProviderContainer container;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('pixel_crochet_provider_');
    storage = ProjectStorageService(baseDirectory: tempDir);
    container = ProviderContainer(
      overrides: [storageServiceProvider.overrideWithValue(storage)],
    );
    addTearDown(container.dispose);
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  CrochetProject sample() => CrochetProject(
        name: 'Sample',
        width: 3,
        height: 3,
        rows: List.generate(
          3,
          (i) => PatternRow(
            rowNumber: i + 1,
            direction: RowDirection.readLeftToRight,
            colorBlocks: [ColorBlock(colorName: 'black', count: 3)],
          ),
        ),
      );

  /// Keeps the autoDispose provider alive for the duration of a test while
  /// waiting for its build to complete.
  Future<CrochetProject> loadProject(String id) async {
    final sub = container.listen(projectProvider(id), (_, _) {});
    addTearDown(sub.close);
    return container.read(projectProvider(id).future);
  }

  test('build loads the project from storage', () async {
    final project = sample();
    await storage.save(project);

    final loaded = await loadProject(project.id);

    expect(loaded.id, project.id);
  });

  test('throws ProjectNotFoundException for a missing project', () async {
    await expectLater(
      container.read(projectProvider('missing').future),
      throwsA(isA<ProjectNotFoundException>()),
    );
  });

  test('toggleBlock updates state and persists', () async {
    final project = sample();
    await storage.save(project);
    await loadProject(project.id);

    await container.read(projectProvider(project.id).notifier).toggleBlock(0);

    final state = container.read(projectProvider(project.id));
    expect(state.value!.isBlockCompleted(0, 0), isTrue);
    final persisted = await storage.load(project.id);
    expect(persisted!.isBlockCompleted(0, 0), isTrue);
  });

  test('setCurrentRow clamps out-of-range indices', () async {
    final project = sample();
    await storage.save(project);
    await loadProject(project.id);

    final notifier = container.read(projectProvider(project.id).notifier);
    await notifier.setCurrentRow(99);

    final state = container.read(projectProvider(project.id));
    expect(state.value!.currentRowIndex, project.rows.length - 1);
  });

  test('reload after invalidation reflects persisted changes', () async {
    final project = sample();
    await storage.save(project);
    await loadProject(project.id);

    await container.read(projectProvider(project.id).notifier).setCurrentRow(2);
    container.invalidate(projectProvider(project.id));

    final reloaded = await container.read(projectProvider(project.id).future);
    expect(reloaded.currentRowIndex, 2);
  });

  test('delete removes the project and refreshes the home list', () async {
    final project = sample();
    await storage.save(project);
    await loadProject(project.id);
    await container.read(projectsProvider.future);

    await container.read(projectProvider(project.id).notifier).delete();

    expect(await storage.load(project.id), isNull);
    final list = await container.read(projectsProvider.future);
    expect(list, isEmpty);
  });
}
