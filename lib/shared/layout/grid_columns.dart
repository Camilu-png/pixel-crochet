/// Returns the grid column count for a given viewport [width].
///
/// Shared by the home and "more patterns" grids so breakpoints stay in sync.
int gridColumns(double width) {
  if (width >= 1200) return 4;
  if (width >= 600) return 3;
  return 2;
}
