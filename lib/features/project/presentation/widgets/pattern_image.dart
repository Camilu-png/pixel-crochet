import 'package:flutter/material.dart';

import '../../../../core/models/crochet_project.dart';
import '../../../../core/theme/context_extensions.dart';
import '../../../../shared/painters/pattern_painter.dart';

class PatternImage extends StatefulWidget {
  const PatternImage({
    super.key,
    required this.project,
    this.highlightRowIndex,
  });

  final CrochetProject project;
  final int? highlightRowIndex;

  @override
  State<PatternImage> createState() => _PatternImageState();
}

class _PatternImageState extends State<PatternImage> {
  final ScrollController _scrollController = ScrollController();
  double _pixelSize = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrentRow());
  }

  @override
  void didUpdateWidget(PatternImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.highlightRowIndex != widget.highlightRowIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrentRow());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrentRow() {
    if (!_scrollController.hasClients) return;
    if (widget.highlightRowIndex == null || _pixelSize <= 0) return;

    final totalRows = widget.project.rows.length;
    final viewportHeight = _scrollController.position.viewportDimension;

    final rowY = (totalRows - 1 - widget.highlightRowIndex!) * _pixelSize;

    double targetOffset = rowY - (viewportHeight / 2) + (_pixelSize / 2);

    targetOffset = targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent);

    _scrollController.jumpTo(targetOffset);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.project.rows.isEmpty) {
      return Center(
        child: Text(
          'No pattern data',
          style: context.text.bodyLarge?.copyWith(
            color: context.colors.brandDark.withValues(alpha: 0.5),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        _pixelSize = constraints.maxWidth / widget.project.width;
        final imageHeight = widget.project.rows.length * _pixelSize;
        final brightness = Theme.of(context).brightness;
        final highlightColor = brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.4)
            : Colors.black.withValues(alpha: 0.15);

        return SingleChildScrollView(
          controller: _scrollController,
          child: CustomPaint(
            size: Size(constraints.maxWidth, imageHeight),
            painter: PatternPainter(
              project: widget.project,
              highlightRowIndex: widget.highlightRowIndex,
              highlightColor: highlightColor,
            ),
          ),
        );
      },
    );
  }
}
