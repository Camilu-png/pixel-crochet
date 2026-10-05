import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_crochet/core/constants/products.dart';
import 'package:pixel_crochet/features/more_patterns/data/free_pattern_catalog.dart';
import 'package:pixel_crochet/generated/app_localizations_en.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'loads each bundled free pattern with valid rows and stitch counts',
    () async {
      final patterns = await const FreePatternCatalog().load();

      expect(patterns.map((pattern) => pattern.id), [
        'blue-guy',
        'yellow-butterfly',
      ]);
      expect(patterns.map((pattern) => pattern.project.width), [32, 82]);
      expect(patterns.map((pattern) => pattern.project.height), [32, 213]);

      for (final pattern in patterns) {
        expect(pattern.project.rows, hasLength(pattern.project.height));
        for (final row in pattern.project.rows) {
          expect(row.totalStitches, pattern.project.width);
        }
      }
    },
  );

  test(
    'creates independent projects with clean progress from a free pattern',
    () async {
      final pattern = (await const FreePatternCatalog().load()).first;
      final first = pattern.createProject(name: 'Blue Guy');
      final second = pattern.createProject(name: 'Blue Guy');

      expect(first.id, isNot(second.id));
      expect(first.currentRowIndex, 0);
      expect(first.completedBlocks, isEmpty);
      expect(first.rows, pattern.project.rows);
    },
  );

  test(
    'changing a copied pattern list cannot mutate the bundled pattern',
    () async {
      final pattern = (await const FreePatternCatalog().load()).first;
      final copy = pattern.createProject(name: 'Copy');

      copy.rows.clear();

      expect(pattern.project.rows, hasLength(pattern.project.height));
    },
  );

  test('keeps the existing Ko-fi product destinations unchanged', () {
    final products = sampleProducts(AppLocalizationsEn());

    expect(products.map((product) => product.kofiUrl), [
      'https://ko-fi.com/s/b121095f37',
      'https://ko-fi.com/s/93a6e28a6c',
    ]);
  });
}
