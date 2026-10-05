import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/crochet_project.dart';
import '../../../core/models/pattern_row.dart';
import '../../import_pattern/data/pattern_parser.dart';

final freePatternsProvider = FutureProvider<List<FreePattern>>((ref) {
  return const FreePatternCatalog().load();
});

class FreePattern {
  const FreePattern({
    required this.id,
    required this.assetPath,
    required this.project,
  });

  final String id;
  final String assetPath;
  final CrochetProject project;

  CrochetProject createProject({required String name}) => CrochetProject(
    name: name,
    width: project.width,
    height: project.height,
    rows: project.rows
        .map(
          (row) => PatternRow(
            rowNumber: row.rowNumber,
            direction: row.direction,
            colorBlocks: List.of(row.colorBlocks),
          ),
        )
        .toList(),
  );
}

class FreePatternCatalog {
  const FreePatternCatalog();

  static const _definitions = [
    (id: 'blue-guy', path: 'example/blue_guy.txt'),
    (id: 'yellow-butterfly', path: 'example/mariposa_amarilla.txt'),
  ];

  Future<List<FreePattern>> load() async {
    const parser = PatternParser();
    final patterns = <FreePattern>[];
    for (final definition in _definitions) {
      final contents = await rootBundle.loadString(definition.path);
      final project = parser.parse(contents);
      patterns.add(
        FreePattern(
          id: definition.id,
          assetPath: definition.path,
          project: project,
        ),
      );
    }
    return List.unmodifiable(patterns);
  }
}
