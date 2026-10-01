import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_crochet/core/models/color_block.dart';
import 'package:pixel_crochet/core/models/crochet_project.dart';
import 'package:pixel_crochet/core/models/pattern_row.dart';
import 'package:pixel_crochet/core/models/row_direction.dart';
import 'package:pixel_crochet/shared/painters/pattern_painter.dart';

void main() {
  CrochetProject project() => CrochetProject(
    name: 'Paint',
    width: 2,
    height: 1,
    rows: [
      PatternRow(
        rowNumber: 1,
        direction: RowDirection.readLeftToRight,
        colorBlocks: [
          ColorBlock(colorName: 'black', count: 1),
          ColorBlock(colorName: 'white', count: 1),
        ],
      ),
    ],
  );

  test('shouldRepaint is false for identical projects', () {
    final painter = PatternPainter(project: project());
    final other = PatternPainter(project: project());

    expect(painter.shouldRepaint(other), isFalse);
  });

  test('shouldRepaint is true when the highlight row changes', () {
    final painter = PatternPainter(project: project(), highlightRowIndex: 0);
    final other = PatternPainter(project: project(), highlightRowIndex: 1);

    expect(painter.shouldRepaint(other), isTrue);
  });

  test('shouldRepaint is true when completed blocks change', () {
    final painter = PatternPainter(project: project());
    final updated = PatternPainter(project: project().toggleBlock(0, 0));

    expect(painter.shouldRepaint(updated), isTrue);
  });

  test('shouldRepaint is true when the double knitting view changes', () {
    final painter = PatternPainter(project: project());
    final inverted = PatternPainter(
      project: project().copyWith(doubleKnitting: true, invertedView: true),
    );

    expect(painter.shouldRepaint(inverted), isTrue);
  });

  group('double knitting rendering', () {
    const black = Color(0xFF2D2D2D);
    const white = Color(0xFFF5F5F5);

    Future<Color> leftHalf(CrochetProject subject) => _pixel(subject, 5);
    Future<Color> rightHalf(CrochetProject subject) => _pixel(subject, 15);

    test('paints the stored colors when the view is not inverted', () async {
      final subject = project().copyWith(doubleKnitting: true);

      expect(await leftHalf(subject), black);
      expect(await rightHalf(subject), white);
    });

    test('exchanges the two colors when the view is inverted', () async {
      final subject = project().copyWith(
        doubleKnitting: true,
        invertedView: true,
      );

      expect(await leftHalf(subject), white);
      expect(await rightHalf(subject), black);
    });

    test('exchanges a right-to-left row of the inverted view too', () async {
      final subject = CrochetProject(
        name: 'Paint',
        width: 2,
        height: 2,
        doubleKnitting: true,
        invertedView: true,
        rows: [
          PatternRow(
            rowNumber: 1,
            direction: RowDirection.readLeftToRight,
            colorBlocks: [ColorBlock(colorName: 'black', count: 2)],
          ),
          PatternRow(
            rowNumber: 2,
            direction: RowDirection.readRightToLeft,
            colorBlocks: [ColorBlock(colorName: 'white', count: 2)],
          ),
        ],
      );

      // Row 2 is the right-to-left one, painted at the top of the canvas, and
      // it must be inverted exactly like the left-to-right row below it.
      expect(await _pixel(subject, 5, y: 0), black);
    });
  });
}

/// Renders [subject] at 20x10 and returns the pixel at [x] on the middle row.
Future<Color> _pixel(CrochetProject subject, int x, {int y = 5}) async {
  final recorder = ui.PictureRecorder();
  PatternPainter(project: subject).paint(Canvas(recorder), const Size(20, 10));

  final image = await recorder.endRecording().toImage(20, 10);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  final offset = ((y * 20) + x) * 4;

  return Color.fromARGB(
    bytes!.getUint8(offset + 3),
    bytes.getUint8(offset),
    bytes.getUint8(offset + 1),
    bytes.getUint8(offset + 2),
  );
}
