import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A Floating Action Button variant with a 3-D depth slab and a
/// continuous floating pulse animation.
///
/// The button bobs up and down in a gentle sine wave, casting a shadow
/// that grows and shrinks to reinforce the illusion of floating height.
///
/// ### Usage
/// ```dart
/// FloatingAction3D(
///   icon: Icons.add,
///   faceColor: Colors.deepOrange,
///   depth: 8,
///   onPressed: () => addItem(),
/// )
/// ```
class FloatingAction3D extends StatefulWidget {
  /// Icon displayed in the centre.
  final IconData icon;

  /// Icon colour.
  final Color iconColor;

  /// Face (top surface) colour.
  final Color faceColor;

  /// Side colour — defaults to a darker shade of [faceColor].
  final Color? sideColor;

  /// Depth of the 3-D slab in logical pixels.
  final double depth;

  /// Diameter of the circular button.
  final double size;

  /// Amplitude of the floating animation in logical pixels.
  final double floatAmplitude;

  /// Duration of one complete float cycle.
  final Duration floatPeriod;

  /// Called on tap. Pass `null` to disable.
  final VoidCallback? onPressed;

  const FloatingAction3D({
    super.key,
    this.icon          = Icons.add,
    this.iconColor     = Colors.white,
    this.faceColor     = const Color(0xFFE91E63),
    this.sideColor,
    this.depth         = 8.0,
    this.size          = 56.0,
    this.floatAmplitude = 6.0,
    this.floatPeriod   = const Duration(milliseconds: 2200),
    this.onPressed,
  });

  @override
  State<FloatingAction3D> createState() => _FloatingAction3DState();
}

class _FloatingAction3DState extends State<FloatingAction3D>
    with SingleTickerProviderStateMixin {
  // Float animation controller runs continuously
  late final AnimationController _floatCtrl = AnimationController(
    vsync: this,
    duration: widget.floatPeriod,
  )..repeat();

  // Press animation
  late final AnimationController _pressCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 80),
  );

  @override
  void dispose() {
    _floatCtrl.dispose();
    _pressCtrl.dispose();
    super.dispose();
  }

  void _down(TapDownDetails _) {
    if (widget.onPressed == null) return;
    _pressCtrl.forward();
  }

  void _up(TapUpDetails _) {
    if (widget.onPressed == null) return;
    _pressCtrl.reverse().then((_) {
      if (mounted) widget.onPressed?.call();
    });
  }

  void _cancel() {
    _pressCtrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveSide =
        widget.sideColor ?? _darkenColor(widget.faceColor, 0.22);
    final disabled = widget.onPressed == null;

    return GestureDetector(
      onTapDown:   disabled ? null : _down,
      onTapUp:     disabled ? null : _up,
      onTapCancel: disabled ? null : _cancel,
      child: AnimatedBuilder(
        animation: Listenable.merge([_floatCtrl, _pressCtrl]),
        builder: (ctx, _) {
          // Sine wave float
          final floatY =
              math.sin(_floatCtrl.value * 2 * math.pi) * widget.floatAmplitude;

          // Press depth
          final pressedDepth = widget.depth * _pressCtrl.value;
          final currentDepth = widget.depth - pressedDepth;

          // Shadow spreads when floating high
          final shadowRadius = 8.0 + (floatY + widget.floatAmplitude) * 0.6;
          final shadowOpacity = 0.25 + (1 - (_floatCtrl.value)) * 0.15;

          return Transform.translate(
            offset: Offset(0, floatY - pressedDepth),
            child: SizedBox(
              width:  widget.size,
              height: widget.size + currentDepth,
              child: CustomPaint(
                painter: _FAB3DPainter(
                  faceColor:     disabled ? Colors.grey.shade400 : widget.faceColor,
                  sideColor:     disabled ? Colors.grey.shade600 : effectiveSide,
                  depth:         currentDepth,
                  shadowRadius:  shadowRadius,
                  shadowOpacity: shadowOpacity,
                  diameter:      widget.size,
                ),
                child: SizedBox(
                  width:  widget.size,
                  height: widget.size,
                  child: Icon(
                    widget.icon,
                    color: disabled ? Colors.white54 : widget.iconColor,
                    size:  widget.size * 0.42,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FAB3DPainter extends CustomPainter {
  final Color faceColor;
  final Color sideColor;
  final double depth;
  final double shadowRadius;
  final double shadowOpacity;
  final double diameter;

  const _FAB3DPainter({
    required this.faceColor,
    required this.sideColor,
    required this.depth,
    required this.shadowRadius,
    required this.shadowOpacity,
    required this.diameter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final r = diameter / 2;
    final center = Offset(r, r);

    // ── Drop shadow ──────────────────────────────────────────────────────────
    canvas.drawCircle(
      Offset(r, r + depth + shadowRadius * 0.3),
      r * 0.85,
      Paint()
        ..color = Colors.black.withAlpha((shadowOpacity * 255).round())
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadowRadius),
    );

    // ── Side slab ────────────────────────────────────────────────────────────
    canvas.drawCircle(
      Offset(r, r + depth),
      r,
      Paint()..color = sideColor,
    );

    // ── Face ─────────────────────────────────────────────────────────────────
    canvas.drawCircle(center, r, Paint()..color = faceColor);

    // ── Highlight ────────────────────────────────────────────────────────────
    canvas.drawCircle(
      Offset(r * 0.75, r * 0.65),
      r * 0.45,
      Paint()
        ..color = Colors.white.withAlpha(35)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_FAB3DPainter old) =>
      old.depth         != depth         ||
      old.shadowRadius  != shadowRadius  ||
      old.shadowOpacity != shadowOpacity ||
      old.faceColor     != faceColor;
}

Color _darkenColor(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
}
