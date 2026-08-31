import 'package:flutter/foundation.dart';

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
    final rawDirection = json['direction'] is int ? json['direction'] as int : 0;
    final direction = RowDirection.values[rawDirection
        .clamp(0, RowDirection.values.length - 1)];
    final colorBlocks = json['colorBlocks'];
    return PatternRow(
      rowNumber: json['rowNumber'] is int ? json['rowNumber'] as int : 0,
      direction: direction,
      colorBlocks: colorBlocks is List
          ? colorBlocks
              .whereType<Map<String, dynamic>>()
              .map(ColorBlock.fromJson)
              .toList()
          : const [],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PatternRow &&
          runtimeType == other.runtimeType &&
          rowNumber == other.rowNumber &&
          direction == other.direction &&
          listEquals(colorBlocks, other.colorBlocks);

  @override
  int get hashCode => Object.hash(rowNumber, direction, colorBlocks);
}
