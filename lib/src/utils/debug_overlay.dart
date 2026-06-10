import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A [Widget] that draws a 3-D axis gizmo (X/Y/Z arrows) in the centre of its
/// parent, controlled by the current rotation matrix.
///
/// Use this during development to visualise how your transforms are oriented.
/// Wrap with `if (kDebugMode)` so it is stripped in release builds.
///
/// ### Usage
/// ```dart
/// Stack(
///   children: [
///     MyScene(),
///     if (kDebugMode)
///       AxisGizmo(
///         rotX: _rotX,
///         rotY: _rotY,
///         size: 80,
///       ),
///   ],
/// )
/// ```
class AxisGizmo extends StatelessWidget {
  final double rotX;
  final double rotY;
  final double size;
  final Alignment alignment;

  const AxisGizmo({
    super.key,
    this.rotX      = 0,
    this.rotY      = 0,
    this.size      = 60,
    this.alignment = Alignment.bottomRight,
  });

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width:  size,
          height: size,
          child: CustomPaint(painter: _GizmoPainter(rotX: rotX, rotY: rotY)),
        ),
      ),
    );
  }
}

class _GizmoPainter extends CustomPainter {
  final double rotX;
  final double rotY;

  const _GizmoPainter({required this.rotX, required this.rotY});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width  / 2;
    final cy = size.height / 2;
    final r  = size.width  / 2 * 0.85;

    const axes = [
      (1.0, 0.0, 0.0, Color(0xFFFF4444), 'X'),  // +X → red
      (0.0, -1.0, 0.0, Color(0xFF44FF44), 'Y'), // +Y → green
      (0.0, 0.0, 1.0, Color(0xFF4488FF), 'Z'),  // +Z → blue
    ];

    for (final (ax, ay, az, color, label) in axes) {
      // Apply rotation
      final ry = ax * math.cos(rotY) + az * math.sin(rotY);
      final rx2 = ry;
      final rz  = -ax * math.sin(rotY) + az * math.cos(rotY);
      final rx3 = rx2;
      final ry2 = ay * math.cos(rotX) - rz * math.sin(rotX);

      final endX = cx + rx3 * r;
      final endY = cy + ry2 * r;

      canvas.drawLine(
        Offset(cx, cy),
        Offset(endX, endY),
        Paint()
          ..color       = color
          ..strokeWidth = 2
          ..strokeCap   = StrokeCap.round,
      );

      final tp = TextPainter(
        text: TextSpan(
          text:  label,
          style: TextStyle(
            color:    color,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(canvas, Offset(endX - 5, endY - 6));
    }

    // Origin dot
    canvas.drawCircle(
      Offset(cx, cy),
      3,
      Paint()..color = Colors.white.withAlpha(180),
    );
  }

  @override
  bool shouldRepaint(_GizmoPainter old) =>
      old.rotX != rotX || old.rotY != rotY;
}

/// A banner-style overlay that shows performance / render debug information.
///
/// Wrap a widget in [DebugBanner3D] to display its live rotation values.
class DebugBanner3D extends StatelessWidget {
  final Widget child;
  final double rotX;
  final double rotY;
  final String? label;

  const DebugBanner3D({
    super.key,
    required this.child,
    this.rotX  = 0,
    this.rotY  = 0,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return child;
    return Stack(
      children: [
        child,
        Positioned(
          top:   4,
          right: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color:        Colors.black54,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${label != null ? "$label | " : ""}'
              'X:${(rotX * 57.3).toStringAsFixed(1)}° '
              'Y:${(rotY * 57.3).toStringAsFixed(1)}°',
              style: const TextStyle(
                color:    Colors.greenAccent,
                fontSize: 9,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
