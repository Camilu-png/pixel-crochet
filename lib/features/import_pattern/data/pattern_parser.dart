import 'package:flutter/foundation.dart';

import '../../../core/models/color_block.dart';
import '../../../core/models/crochet_project.dart';
import '../../../core/models/pattern_row.dart';
import '../../../core/models/row_direction.dart';

class PatternParser {
  const PatternParser();

  CrochetProject parse(String content) {
    final lines = content.split('\n').where((l) => l.trim().isNotEmpty).toList();
    
    if (lines.length < 3) {
      throw FormatException('Invalid pattern format: too few lines');
    }

    final name = _parseName(lines[0]);
    final dimensions = _parseDimensions(lines[1]);
    if (dimensions.$1 < 1 || dimensions.$2 < 1) {
      throw FormatException(
        'Invalid pattern format: dimensions must be positive (${dimensions.$1}x${dimensions.$2})',
      );
    }
    var rows = <PatternRow>[];

    for (var i = 2; i < lines.length; i++) {
      final row = _parseRow(lines[i]);
      if (row != null) {
        rows.add(row);
      }
    }

    if (rows.isEmpty) {
      throw FormatException('No valid rows found in pattern');
    }

    if (rows.length != dimensions.$2) {
      throw FormatException(
        'Row count (${rows.length}) does not match declared height (${dimensions.$2})',
      );
    }

    // Reverse list and renumber: first in project = first crochet row (bottom of image)
    rows = rows.reversed.toList();
    for (var i = 0; i < rows.length; i++) {
      rows[i] = PatternRow(
        rowNumber: i + 1,
        direction: rows[i].direction,
        colorBlocks: rows[i].colorBlocks,
      );
    }

    return CrochetProject(
      name: name,
      width: dimensions.$1,
      height: dimensions.$2,
      rows: rows,
    );
  }

  String _parseName(String line) {
    // Remove emoji prefix and trim
    final name = line.replaceFirst(RegExp(r'^[^\w]*'), '').trim();
    if (name.isEmpty) {
      throw FormatException('Invalid pattern format: missing project name');
    }
    return name;
  }

  (int, int) _parseDimensions(String line) {
    final match = RegExp(r'(\d+)\s*x\s*(\d+)').firstMatch(line);
    if (match == null) {
      throw FormatException('Invalid pattern format: invalid dimensions');
    }
    return (int.parse(match.group(1)!), int.parse(match.group(2)!));
  }

  PatternRow? _parseRow(String line) {
    // Match: "Row 1 <-: 30 black, 21 gray, 31 black"
    final match = RegExp(
      r'Row\s+(\d+)\s+(<-|->):\s*(.*)',
    ).firstMatch(line);
    
    if (match == null) return null;

    final rowNumber = int.parse(match.group(1)!);
    final direction = match.group(2) == '<-'
        ? RowDirection.readLeftToRight
        : RowDirection.readRightToLeft;
    final colorBlocksStr = match.group(3)!;

    final colorBlocks = _parseColorBlocks(colorBlocksStr);

    return PatternRow(
      rowNumber: rowNumber,
      direction: direction,
      colorBlocks: colorBlocks,
    );
  }

  List<ColorBlock> _parseColorBlocks(String str) {
    final blocks = <ColorBlock>[];
    final parts = str.split(',');

    for (final part in parts) {
      final match = RegExp(r'(\d+)\s+(\w+)').firstMatch(part.trim());
      if (match != null) {
        final count = int.parse(match.group(1)!);
        if (count < 1) continue;
        final colorName = match.group(2)!;
        blocks.add(ColorBlock(colorName: colorName, count: count));
      }
    }

    return blocks;
  }

  /// Parses [content] off the UI thread so large patterns never jank the
  /// interface. Not available on all platforms; falls back to synchronous
  /// parsing when isolates are unsupported.
  Future<CrochetProject> parseAsync(String content) async {
    try {
      return await compute(_parseIsolate, content);
    } on UnsupportedError {
      return parse(content);
    }
  }
}

CrochetProject _parseIsolate(String content) =>
    const PatternParser().parse(content);
