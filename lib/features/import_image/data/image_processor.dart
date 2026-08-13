import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:image/image.dart' as img;

import '../../../core/constants/color_map.dart';
import '../../../core/models/color_block.dart';
import '../../../core/models/crochet_project.dart';
import '../../../core/models/pattern_row.dart';
import '../../../core/models/row_direction.dart';

class ImageProcessor {
  const ImageProcessor();

  static const int maxStitches = 100000;
  static const int _quantizeStep = 16;
  static const double _colorMatchThreshold = 60.0;

  /// Decodes and samples [path] off the UI thread.
  Future<ImageData> loadImageAsync(String path) {
    return compute(_loadImageIsolate, path);
  }

  /// Runs grid extraction and palette detection off the UI thread.
  Future<GridProcessingResult> processGridAsync(
    ImageData data,
    int stitchesWide,
    int stitchesHigh,
  ) {
    return compute(_processGridIsolate, (data, stitchesWide, stitchesHigh));
  }

  ImageData loadImage(String path) {
    final file = File(path);
    final bytes = file.readAsBytesSync();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw const ImageProcessingException('corruptedImage');
    }
    if (decoded.width == 0 || decoded.height == 0) {
      throw const ImageProcessingException('invalidImageDimensions');
    }

    final pixels = <Color>[];
    for (var y = 0; y < decoded.height; y++) {
      for (var x = 0; x < decoded.width; x++) {
        final p = decoded.getPixel(x, y);
        pixels.add(Color.fromARGB(
          p.a.toInt(),
          p.r.toInt(),
          p.g.toInt(),
          p.b.toInt(),
        ));
      }
    }

    return ImageData(
      width: decoded.width,
      height: decoded.height,
      pixels: pixels,
    );
  }

  GridInfo computeGrid(int imgWidth, int imgHeight, int stitchesWide, int stitchesHigh) {
    return GridInfo(
      cellWidth: imgWidth / stitchesWide,
      cellHeight: imgHeight / stitchesHigh,
      numCols: stitchesWide,
      numRows: stitchesHigh,
    );
  }

  List<List<Color>> extractMatrix(ImageData data, GridInfo grid) {
    final matrix = <List<Color>>[];

    for (var row = 0; row < grid.numRows; row++) {
      final rowColors = <Color>[];
      for (var col = 0; col < grid.numCols; col++) {
        final cellColor = _sampleCell(data, grid, col, row);
        rowColors.add(cellColor);
      }
      matrix.add(rowColors);
    }

    return matrix;
  }

  List<DetectedColor> detectPalette(List<List<Color>> matrix) {
    final uniqueBuckets = <int>{};
    for (final row in matrix) {
      for (final color in row) {
        uniqueBuckets.add(_colorBucket(color));
      }
    }

    final palette = uniqueBuckets.map((bucket) {
      final color = _bucketToColor(bucket);
      return DetectedColor(
        id: colorIdentifier(color),
        color: color,
      );
    }).toList();

    palette.sort((a, b) => _luminance(a.color).compareTo(_luminance(b.color)));
    return palette;
  }

  double _luminance(Color c) => 0.299 * c.r + 0.587 * c.g + 0.114 * c.b;

  List<List<Color>> replaceColorsInMatrix(
    List<List<Color>> matrix,
    Color oldColor,
    Color newColor,
  ) {
    return matrix.map((row) {
      return row.map((color) {
        return color.toARGB32() == oldColor.toARGB32() ? newColor : color;
      }).toList();
    }).toList();
  }

  CrochetProject generateProject(
    String name,
    List<List<Color>> matrix,
  ) {
    final rows = <PatternRow>[];

    for (var i = matrix.length - 1; i >= 0; i--) {
      final rowColors = matrix[i];
      final crochetIndex = matrix.length - 1 - i;
      final direction = crochetIndex % 2 == 0
          ? RowDirection.readLeftToRight
          : RowDirection.readRightToLeft;

      final processedColors = direction == RowDirection.readLeftToRight
          ? rowColors
          : rowColors.reversed.toList();

      final blocks = <ColorBlock>[];
      var currentId = colorIdentifier(processedColors.first);
      var currentCount = 1;

      for (var j = 1; j < processedColors.length; j++) {
        final id = colorIdentifier(processedColors[j]);
        if (id == currentId) {
          currentCount++;
        } else {
          blocks.add(ColorBlock(colorName: currentId, count: currentCount));
          currentId = id;
          currentCount = 1;
        }
      }
      blocks.add(ColorBlock(colorName: currentId, count: currentCount));

      rows.add(PatternRow(
        rowNumber: crochetIndex + 1,
        direction: direction,
        colorBlocks: blocks,
      ));
    }

    return CrochetProject(
      name: name,
      width: matrix.isNotEmpty ? matrix.first.length : 0,
      height: matrix.length,
      rows: rows,
    );
  }

  Color _sampleCell(ImageData data, GridInfo grid, int col, int row) {
    final left = (col * grid.cellWidth).floor();
    final top = (row * grid.cellHeight).floor();
    final right = ((col + 1) * grid.cellWidth).ceil();
    final bottom = ((row + 1) * grid.cellHeight).ceil();

    final freq = <int, int>{};

    for (var y = top; y < bottom; y++) {
      for (var x = left; x < right; x++) {
        final clampedX = x.clamp(0, data.width - 1);
        final clampedY = y.clamp(0, data.height - 1);
        final pixel = data.pixels[clampedY * data.width + clampedX];
        final bucket = _colorBucket(pixel);
        freq[bucket] = (freq[bucket] ?? 0) + 1;
      }
    }

    if (freq.isEmpty) return const Color(0xFFFFFFFF);

    final modeBucket = freq.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    ).key;

    return _bucketToColor(modeBucket);
  }

  int _colorBucket(Color c) {
    final r = ((c.r * 255).round() / _quantizeStep).round();
    final g = ((c.g * 255).round() / _quantizeStep).round();
    final b = ((c.b * 255).round() / _quantizeStep).round();
    return (r << 16) | (g << 8) | b;
  }

  Color _bucketToColor(int bucket) {
    final r = ((bucket >> 16) & 0xFF) * _quantizeStep;
    final g = ((bucket >> 8) & 0xFF) * _quantizeStep;
    final b = (bucket & 0xFF) * _quantizeStep;
    return Color.fromARGB(
      255,
      r.clamp(0, 255),
      g.clamp(0, 255),
      b.clamp(0, 255),
    );
  }

  String colorIdentifier(Color color) {
    String? bestName;
    var bestDistance = double.infinity;

    for (final entry in yarnColors.entries) {
      final d = _colorDistanceSquared(color, entry.value);
      if (d < bestDistance) {
        bestDistance = d;
        bestName = entry.key;
      }
    }

    if (bestName != null && bestDistance <= _colorMatchThreshold * _colorMatchThreshold) {
      return bestName;
    }

    return colorToHex(color);
  }

  double _colorDistanceSquared(Color a, Color b) {
    final dr = a.r - b.r;
    final dg = a.g - b.g;
    final db = a.b - b.b;
    return dr * dr + dg * dg + db * db;
  }

  String colorToHex(Color c) {
    final r = (c.r * 255).round().toRadixString(16).padLeft(2, '0');
    final g = (c.g * 255).round().toRadixString(16).padLeft(2, '0');
    final b = (c.b * 255).round().toRadixString(16).padLeft(2, '0');
    return '#$r$g$b';
  }
}

class ImageProcessingException implements Exception {
  const ImageProcessingException(this.code);

  /// Machine-readable error code mapped to a localized message in the UI.
  final String code;
}

class ImageData {
  ImageData({
    required this.width,
    required this.height,
    required this.pixels,
  });

  final int width;
  final int height;
  final List<Color> pixels;
}

class GridInfo {
  GridInfo({
    required this.cellWidth,
    required this.cellHeight,
    required this.numCols,
    required this.numRows,
  });

  final double cellWidth;
  final double cellHeight;
  final int numCols;
  final int numRows;
}

class DetectedColor {
  DetectedColor({
    required this.id,
    required this.color,
  });

  final String id;
  final Color color;
}

class GridProcessingResult {
  GridProcessingResult({
    required this.grid,
    required this.matrix,
    required this.palette,
  });

  final GridInfo grid;
  final List<List<Color>> matrix;
  final List<DetectedColor> palette;
}

ImageData _loadImageIsolate(String path) => ImageProcessor().loadImage(path);

GridProcessingResult _processGridIsolate((ImageData, int, int) args) {
  final (data, stitchesWide, stitchesHigh) = args;
  final processor = ImageProcessor();
  final grid = processor.computeGrid(
    data.width,
    data.height,
    stitchesWide,
    stitchesHigh,
  );
  final matrix = processor.extractMatrix(data, grid);
  final palette = processor.detectPalette(matrix);
  return GridProcessingResult(grid: grid, matrix: matrix, palette: palette);
}
