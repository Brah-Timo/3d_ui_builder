import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A text label that continuously bobs up and down as if floating in zero
/// gravity.
///
/// The float animation is a smooth sine wave applied via [Transform.translate].
/// An optional glow effect reinforces the floating appearance.
///
/// ### Usage
/// ```dart
/// FloatingLabel(
///   'Score: 9999',
///   style:     TextStyle(color: Colors.amber, fontSize: 22, fontWeight: FontWeight.bold),
///   amplitude: 8,
///   period:    Duration(milliseconds: 2000),
///   glow:      true,
///   glowColor: Colors.amber,
/// )
/// ```
class FloatingLabel extends StatefulWidget {
  final String text;
  final TextStyle? style;

  /// Amplitude of the vertical oscillation in logical pixels.
  final double amplitude;

  /// Duration of one complete up-down cycle.
  final Duration period;

  /// Whether to add a soft glow shadow behind the text.
  final bool glow;

  /// Glow colour.  Defaults to the text colour.
  final Color? glowColor;

  /// Phase offset (0.0–1.0) for staggering multiple [FloatingLabel]s.
  final double phaseOffset;

  const FloatingLabel(
    this.text, {
    super.key,
    this.style,
    this.amplitude   = 6,
    this.period      = const Duration(milliseconds: 2000),
    this.glow        = false,
    this.glowColor,
    this.phaseOffset = 0,
  });

  @override
  State<FloatingLabel> createState() => _FloatingLabelState();
}

class _FloatingLabelState extends State<FloatingLabel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: widget.period,
  )..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = widget.style ??
        DefaultTextStyle.of(context).style;

    final glowColor = widget.glowColor ?? effectiveStyle.color ?? Colors.white;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (ctx, child) {
        final phase  = (_ctrl.value + widget.phaseOffset) % 1.0;
        final offset = math.sin(phase * 2 * math.pi) * widget.amplitude;

        return Transform.translate(
          offset: Offset(0, offset),
          child: child,
        );
      },
      child: Text(
        widget.text,
        style: widget.glow
            ? effectiveStyle.copyWith(
                shadows: [
                  Shadow(
                    color:      glowColor.withAlpha(180),
                    blurRadius: 16,
                    offset:     Offset.zero,
                  ),
                  Shadow(
                    color:      glowColor.withAlpha(100),
                    blurRadius: 32,
                    offset:     Offset.zero,
                  ),
                ],
              )
            : effectiveStyle,
      ),
    );
  }
}
