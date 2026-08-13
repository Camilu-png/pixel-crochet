import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_crochet/core/models/color_block.dart';
import 'package:pixel_crochet/core/models/crochet_project.dart';
import 'package:pixel_crochet/core/models/pattern_row.dart';
import 'package:pixel_crochet/core/models/row_direction.dart';
import 'package:pixel_crochet/core/storage/project_storage_service.dart';

void main() {
  late Directory tempDir;
  late ProjectStorageService storage;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('pixel_crochet_storage_');
    storage = ProjectStorageService(baseDirectory: tempDir);
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  CrochetProject sample() => CrochetProject(
        name: 'Sample',
        width: 3,
        height: 1,
        rows: [
          PatternRow(
            rowNumber: 1,
            direction: RowDirection.readLeftToRight,
            colorBlocks: [ColorBlock(colorName: 'black', count: 3)],
          ),
        ],
      );

  test('save and load round-trips a project', () async {
    final project = sample();
    await storage.save(project);

    final loaded = await storage.load(project.id);

    expect(loaded, isNotNull);
    expect(loaded!.name, project.name);
    expect(loaded.width, project.width);
    expect(loaded.currentRowIndex, project.currentRowIndex);
    expect(loaded.rows.single.colorBlocks.single.colorName, 'black');
  });

  test('load returns null for a missing project', () async {
    expect(await storage.load('missing-id'), isNull);
  });

  test('loadAll returns projects sorted by createdAt (newest first)', () async {
    final older = sample();
    await storage.save(older);

    final newer = CrochetProject(
      name: 'Newer',
      width: 1,
      height: 1,
      rows: older.rows,
      createdAt: DateTime.now().add(const Duration(minutes: 1)),
    );
    await storage.save(newer);

    final all = await storage.loadAll();

    expect(all.map((p) => p.name).toList(), ['Newer', 'Sample']);
  });

  test('loadAll skips corrupted files', () async {
    final projectsDir = Directory('${tempDir.path}/projects')
      ..createSync(recursive: true);
    File('${projectsDir.path}/corrupt.json').writeAsStringSync('not json');

    final project = sample();
    await storage.save(project);

    final all = await storage.loadAll();

    expect(all.length, 1);
    expect(all.first.id, project.id);
  });

  test('delete removes the project file', () async {
    final project = sample();
    await storage.save(project);
    expect(await storage.load(project.id), isNotNull);

    await storage.delete(project.id);

    expect(await storage.load(project.id), isNull);
  });
}
