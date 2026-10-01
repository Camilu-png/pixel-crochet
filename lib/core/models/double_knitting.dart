/// Two-color inversion rules for double knitting.
library;

import 'color_block.dart';
import 'crochet_project.dart';
import 'pattern_row.dart';

/// Returns the color exchange map for a two-color project, or an empty map
/// when [colors] does not hold exactly two distinct colors.
///
/// The exchange is symmetric (`A -> B`, `B -> A`), so neither color has a
/// privileged "first" role.
Map<String, String> buildColorSwap(Iterable<String> colors) {
  final distinct = colors.toSet();
  if (distinct.length != 2) return const {};

  final iterator = distinct.iterator;
  iterator.moveNext();
  final first = iterator.current;
  iterator.moveNext();
  final second = iterator.current;

  return {first: second, second: first};
}

/// Exchanges the colors of [row] according to [swap].
///
/// In double knitting the reverse face of the work is the exact color negative
/// of the front one: every cell of the inverted view shows the other color,
/// left-to-right and right-to-left rows alike. The row direction therefore
/// plays no part, and an empty [swap] is a no-op.
///
/// Block counts are preserved — only each block's [ColorBlock.colorName]
/// changes — so the row still describes the same number of stitches.
PatternRow swapRowColors(PatternRow row, Map<String, String> swap) {
  if (swap.isEmpty) return row;

  return PatternRow(
    rowNumber: row.rowNumber,
    direction: row.direction,
    colorBlocks: row.colorBlocks
        .map(
          (block) => ColorBlock(
            colorName: swap[block.colorName] ?? block.colorName,
            count: block.count,
          ),
        )
        .toList(),
  );
}

/// The distinct yarn names actually used by [project]'s rows.
///
/// This is the single source of truth for deciding whether a project qualifies
/// for double knitting: the app stores no palette, so a project's colors are
/// only ever knowable from its blocks.
Set<String> distinctProjectColors(CrochetProject project) {
  return project.rows
      .expand((row) => row.colorBlocks)
      .map((block) => block.colorName)
      .toSet();
}
