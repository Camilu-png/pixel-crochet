import 'package:flutter/material.dart';

import 'color_block.dart';
import 'row_direction.dart';

@immutable
class PatternRow {
  const PatternRow({
    required this.rowNumber,
    required this.direction,
    required this.colorBlocks,
  });

  final int rowNumber;
  final RowDirection direction;
  final List<ColorBlock> colorBlocks;

  int get totalStitches =>
      colorBlocks.fold(0, (sum, block) => sum + block.count);

  Map<String, dynamic> toJson() => {
        'rowNumber': rowNumber,
        'direction': direction.index,
        'colorBlocks': colorBlocks.map((b) => b.toJson()).toList(),
      };

  factory PatternRow.fromJson(Map<String, dynamic> json) {
    return PatternRow(
      rowNumber: json['rowNumber'] as int,
      direction: RowDirection.values[json['direction'] as int],
      colorBlocks: (json['colorBlocks'] as List)
          .map((b) => ColorBlock.fromJson(b as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PatternRow &&
          runtimeType == other.runtimeType &&
          rowNumber == other.rowNumber &&
          direction == other.direction;

  @override
  int get hashCode => Object.hash(rowNumber, direction);
}
