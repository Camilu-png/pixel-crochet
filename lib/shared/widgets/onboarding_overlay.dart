import 'package:flutter/material.dart';

import '../../core/theme/context_extensions.dart';

/// A single step shown inside an [OnboardingOverlay].
class OnboardingStep {
  const OnboardingStep({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}

/// A lightweight full-screen overlay that walks a first-time user through a
/// screen one step at a time.
///
/// Pass multiple steps to chain them with a "Next" button; the last step's
/// button reads as the `doneLabel`. Swiping/tapping outside is disabled so the
/// user reads each tip before continuing.
class OnboardingOverlay extends StatefulWidget {
  const OnboardingOverlay({
    super.key,
    required this.steps,
    required this.doneLabel,
    this.nextLabel,
  });

  final List<OnboardingStep> steps;
  final String doneLabel;
  final String? nextLabel;

  @override
  State<OnboardingOverlay> createState() => _OnboardingOverlayState();
}

class _OnboardingOverlayState extends State<OnboardingOverlay> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = 0;
  }

  bool get _isLast => _index == widget.steps.length - 1;

  void _advance() {
    if (_isLast) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _index++);
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.steps[_index];

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black.withValues(alpha: 0.6),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Material(
                color: context.colors.brandIvory,
                borderRadius: BorderRadius.circular(20),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        step.icon,
                        size: 56,
                        color: context.colors.brandLavender,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        step.title,
                        textAlign: TextAlign.center,
                        style: context.text.titleLarge?.copyWith(
                          color: context.colors.brandDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        step.description,
                        textAlign: TextAlign.center,
                        style: context.text.bodyMedium?.copyWith(
                          color: context.colors.brandDark.withValues(
                            alpha: 0.7,
                          ),
                          height: 1.4,
                        ),
                      ),
                      if (widget.steps.length > 1) ...[
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (var i = 0; i < widget.steps.length; i++)
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                ),
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: i == _index
                                      ? context.colors.brandLavender
                                      : context.colors.brandLavender.withValues(
                                          alpha: 0.25,
                                        ),
                                ),
                              ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _advance,
                          child: Text(
                            _isLast
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
        ),
      ),
    );
  }
}
