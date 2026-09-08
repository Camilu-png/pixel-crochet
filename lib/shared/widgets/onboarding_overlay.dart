import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/context_extensions.dart';

/// A single step shown inside an [OnboardingOverlay].
///
/// Set [targetKey] to the [GlobalKey] of the widget this step should visually
/// spotlight (darken everything around it). When it is `null` the step is
/// shown as a plain centered card with no spotlight.
class OnboardingStep {
  const OnboardingStep({
    required this.icon,
    required this.title,
    required this.description,
    this.targetKey,
  });

  final IconData icon;
  final String title;
  final String description;
  final GlobalKey? targetKey;
}

/// A screen-level spotlight that walks a user through a screen one step at a
/// time.
///
/// Unlike a full-screen dialog, this widget wraps the screen's [child] in a
/// [Stack] and overlays a dark veil with a transparent "hole" cut over the
/// widget referenced by the current step's [OnboardingStep.targetKey]. The
/// explanation is drawn in a floating card near the highlighted element, while
/// [IgnorePointer] keeps scroll and interaction working so the user can look
/// around.
///
/// When [active] becomes `true` each step's target is scrolled into view
/// automatically. Each tip must be advanced with the "Next" / "Done" button.
class OnboardingOverlay extends StatefulWidget {
  const OnboardingOverlay({
    super.key,
    required this.active,
    required this.steps,
    required this.doneLabel,
    this.nextLabel,
    required this.child,
    this.onDismiss,
  });

  /// Whether the spotlight is currently shown. Keep it `true` while the user
  /// navigates the steps; set it to `false` (and call [onDismiss]) when done.
  final bool active;

  final List<OnboardingStep> steps;
  final String doneLabel;
  final String? nextLabel;

  /// The screen content to wrap.
  final Widget child;

  /// Called when the user reaches the last step and taps the done button.
  final VoidCallback? onDismiss;

  @override
  State<OnboardingOverlay> createState() => _OnboardingOverlayState();
}

class _OnboardingOverlayState extends State<OnboardingOverlay> {
  int _index = 0;

  bool get _isLast => _index == widget.steps.length - 1;

  @override
  void didUpdateWidget(OnboardingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When (re)activated, restart from the first step.
    if (widget.active && !oldWidget.active) {
      _index = 0;
    }
  }

  void _advance() {
    if (_isLast) {
      widget.onDismiss?.call();
      return;
    }
    setState(() => _index++);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) return widget.child;

    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: _SpotlightLayer(
            step: widget.steps[_index],
            isLast: _isLast,
            doneLabel: widget.doneLabel,
            nextLabel: widget.nextLabel,
            onAdvance: _advance,
          ),
        ),
      ],
    );
  }
}

/// Paints the dark veil (with a transparent hole over the target) and renders
/// the floating tip card. Repaints every frame so the hole follows scrolling.
class _SpotlightLayer extends StatefulWidget {
  const _SpotlightLayer({
    required this.step,
    required this.isLast,
    required this.doneLabel,
    required this.nextLabel,
    required this.onAdvance,
  });

  final OnboardingStep step;
  final bool isLast;
  final String doneLabel;
  final String? nextLabel;
  final VoidCallback onAdvance;

  @override
  State<_SpotlightLayer> createState() => _SpotlightLayerState();
}

class _SpotlightLayerState extends State<_SpotlightLayer> {
  Rect? _targetRect;
  double _tooltipHeight = 240;
  final _cardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureVisible();
      _syncTarget();
    });
  }

  @override
  void didUpdateWidget(_SpotlightLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.step.targetKey != widget.step.targetKey) {
      _ensureVisible();
    }
  }

  void _ensureVisible() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = widget.step.targetKey?.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          alignment: 0.5,
          // Keep room for the floating card below/above the target.
          alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
        );
      }
    });
  }

  void _syncTarget() {
    if (!mounted) return;
    var changed = false;

    final ctx = widget.step.targetKey?.currentContext;
    final box = ctx?.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize && box.attached) {
      final rect = box.localToGlobal(Offset.zero) & box.size;
      if (rect != _targetRect) {
        _targetRect = rect;
        changed = true;
      }
    }

    // Measure the actual tooltip height so it is placed on a side where it
    // never overlaps the highlighted element.
    final cardBox = _cardKey.currentContext?.findRenderObject() as RenderBox?;
    if (cardBox != null && cardBox.hasSize && cardBox.attached) {
      final height = cardBox.size.height;
      if ((height - _tooltipHeight).abs() > 0.5) {
        _tooltipHeight = height;
        changed = true;
      }
    }

    if (changed) setState(() {});
    // Keep tracking position for the next frame.
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncTarget());
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _SpotlightPainter(targetRect: _targetRect),
            ),
          ),
        ),
        // Always expose the card (and its dismiss button), even when the
        // highlighted element is not currently mounted, so the overlay can
        // never trap the user.
        _buildTooltip(context, _targetRect),
      ],
    );
  }

  Widget _buildTooltip(BuildContext context, Rect? target) {
    final size = MediaQuery.sizeOf(context);
    const cardWidth = 300.0;
    const gap = 12.0;

    final cardHeight = _tooltipHeight;
    final step = widget.step;

    double top;
    if (target == null) {
      // No highlighted element on screen: center the card.
      top = math.max(8, (size.height - cardHeight) / 2);
    } else {
      // Prefer to place the card fully above the target; fall back to below;
      // as a last resort center it (the card is capped so it always fits).
      final spaceAbove = target.top - 8;
      final spaceBelow = size.height - target.bottom - 8;
      if (spaceAbove >= cardHeight + gap) {
        top = target.top - cardHeight - gap;
      } else if (spaceBelow >= cardHeight + gap) {
        top = target.bottom + gap;
      } else {
        top = math.max(8, (size.height - cardHeight) / 2);
      }
    }

    // Center the card over the target area (or the screen when there is no
    // target), keeping it on-screen.
    final targetCenterDx = target?.center.dx ?? size.width / 2;
    final left = (targetCenterDx - cardWidth / 2)
        .clamp(8.0, math.max(8.0, size.width - cardWidth - 8))
        .toDouble();

    return Positioned(
      top: top,
      left: left,
      width: cardWidth,
      child: Material(
        key: _cardKey,
        color: context.colors.brandLavender,
        elevation: 12,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: size.height - 16),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(step.icon, color: Colors.white, size: 26),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          step.title,
                          style: context.text.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    step.description,
                    style: context.text.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.95),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 44,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: context.colors.brandLavender,
                      ),
                      onPressed: widget.onAdvance,
                      child: Text(
                        widget.isLast
                            ? widget.doneLabel
                            : (widget.nextLabel ?? ''),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _targetRect = null;
    super.dispose();
  }
}

/// Paints the semi-transparent veil across the whole screen, cutting a
/// rounded-rectangle "hole" (using `BlendMode.clear`) over the target widget.
class _SpotlightPainter extends CustomPainter {
  _SpotlightPainter({required this.targetRect});

  final Rect? targetRect;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;

    canvas.saveLayer(bounds, Paint());

    final veil = Paint()..color = Colors.black.withValues(alpha: 0.6);
    canvas.drawRect(bounds, veil);

    if (targetRect != null) {
      final hole = RRect.fromRectAndRadius(
        targetRect!.inflate(10),
        const Radius.circular(14),
      );
      final cut = Paint()
        ..blendMode = BlendMode.clear
        ..isAntiAlias = true;
      canvas.drawRRect(hole, cut);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_SpotlightPainter oldDelegate) =>
      oldDelegate.targetRect != targetRect;
}
