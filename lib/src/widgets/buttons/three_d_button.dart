import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// A button with a real 3-D depth effect that physically presses in on tap.
///
/// The button is painted with a [CustomPainter] that draws:
/// - A rounded-rect **face** (top surface).
/// - A rounded-rect **side** slab offset downward by [depth] pixels,
///   giving the illusion of a three-dimensional block.
/// - Optionally a **highlight** streak on the top-left edge.
///
/// On tap-down the face travels the full [depth] toward the viewer,
/// snapping back on tap-up with a configurable spring.
///
/// ### Usage
/// ```dart
/// ThreeDButton(
///   label: const Text('Launch'),
///   depth: 8,
///   faceColor: Colors.deepPurple,
///   onPressed: () => doLaunch(),
/// )
/// ```
class ThreeDButton extends StatefulWidget {
  /// The widget shown on the button face (usually a [Text] or [Icon]).
  final Widget label;

  /// Called when the button is tapped. Pass `null` to disable.
  final VoidCallback? onPressed;

  /// The depth of the 3-D block in logical pixels.
  final double depth;

  /// The top-face colour.
  final Color faceColor;

  /// The side-face colour.  Defaults to a darker shade of [faceColor].
  final Color? sideColor;

  /// Corner radius of the button shape.
  final double borderRadius;

  /// Inner padding around [label].
  final EdgeInsets padding;

  /// Whether to show a specular highlight streak on the top edge.
  final bool showHighlight;

  /// Duration of the press-down animation.
  final Duration pressDuration;

  const ThreeDButton({
    super.key,
    required this.label,
    this.onPressed,
    this.depth         = 6.0,
    this.faceColor     = const Color(0xFF5C6BC0),
    this.sideColor,
    this.borderRadius  = 12.0,
    this.padding       = const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
    this.showHighlight = true,
    this.pressDuration = const Duration(milliseconds: 80),
  });

  @override
  State<ThreeDButton> createState() => _ThreeDButtonState();
}

class _ThreeDButtonState extends State<ThreeDButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: widget.pressDuration,
    value: 0,
  );

  late final Animation<double> _pressAnim = Tween<double>(
    begin: 0,
    end:   1,
  ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

  // ─── Gesture ──────────────────────────────────────────────────────────────

  void _onTapDown(TapDownDetails _) {
    if (widget.onPressed == null) return;
    _ctrl.forward();
  }

  void _onTapUp(TapUpDetails _) {
    if (widget.onPressed == null) return;
    _ctrl.reverse().then((_) => widget.onPressed?.call());
  }

  void _onTapCancel() => _ctrl.reverse();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveSide = widget.sideColor ??
        _darkenColor(widget.faceColor, 0.22);

    final disabled = widget.onPressed == null;

    return GestureDetector(
      onTapDown:   disabled ? null : _onTapDown,
      onTapUp:     disabled ? null : _onTapUp,
      onTapCancel: disabled ? null : _onTapCancel,
      child: AnimatedBuilder(
        animation: _pressAnim,
        builder: (ctx, child) {
          final pressed = widget.depth * _pressAnim.value;
          final current = widget.depth - pressed;

          return CustomPaint(
            painter: _ThreeDButtonPainter(
              faceColor:     disabled ? Colors.grey.shade400 : widget.faceColor,
              sideColor:     disabled ? Colors.grey.shade600 : effectiveSide,
              depth:         current,
              borderRadius:  widget.borderRadius,
              showHighlight: widget.showHighlight && !disabled,
            ),
            child: Padding(
              // Shift label down as button presses
              padding: widget.padding.copyWith(
                top:    widget.padding.top    + pressed,
                bottom: widget.padding.bottom - pressed,
              ),
              child: child,
            ),
          );
        },
        child: widget.label,
      ),
    );
  }
}

// ─── Painter ──────────────────────────────────────────────────────────────────

class _ThreeDButtonPainter extends CustomPainter {
  final Color faceColor;
  final Color sideColor;
  final double depth;
  final double borderRadius;
  final bool showHighlight;

  const _ThreeDButtonPainter({
    required this.faceColor,
    required this.sideColor,
    required this.depth,
    required this.borderRadius,
    required this.showHighlight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final br = Radius.circular(borderRadius);

    // ── Side slab ────────────────────────────────────────────────────────────
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, depth, size.width, size.height),
        br,
      ),
      Paint()..color = sideColor,
    );

    // ── Face ─────────────────────────────────────────────────────────────────
    final faceRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      br,
    );
    canvas.drawRRect(faceRect, Paint()..color = faceColor);

    // ── Highlight streak ─────────────────────────────────────────────────────
    if (showHighlight) {
      final highlightPaint = Paint()
        ..shader = ui.Gradient.linear(
          const Offset(0, 0),
          Offset(size.width * 0.6, size.height * 0.4),
          [
            Colors.white.withAlpha(60),
            Colors.white.withAlpha(0),
          ],
        );
      canvas.drawRRect(faceRect, highlightPaint);
    }
  }

  @override
  bool shouldRepaint(_ThreeDButtonPainter old) =>
      old.depth     != depth     ||
      old.faceColor != faceColor ||
      old.sideColor != sideColor;
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

Color _darkenColor(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
}
