import 'package:flutter/material.dart';

/// A [CustomPainter] that draws a fake specular reflection streak on a surface.
///
/// The streak is a gradient oval that sweeps across the surface, simulating
/// a moving highlight as if the surface were lit from the top-left.
///
/// This is a 2-D approximation — no actual raycasting — but it reads
/// convincingly for glossy materials.
///
/// ### Usage
/// ```dart
/// CustomPaint(
///   painter: ReflectionPainter(
///     reflectColor: Colors.white,
///     intensity:    0.25,
///     angle:        -0.5,   // radians, -π/2 → π/2
///   ),
///   child: MyGlossyWidget(),
/// )
/// ```
class ReflectionPainter extends CustomPainter {
  /// Base colour of the highlight (usually white or near-white).
  final Color reflectColor;

  /// Opacity multiplier [0, 1].
  final double intensity;

  /// Tilt angle of the reflection streak in radians.
  final double angle;

  /// Relative width of the streak: 0 = point, 1 = full width.
  final double width;

  /// Relative position across the surface: 0 = left edge, 1 = right edge.
  final double position;

  const ReflectionPainter({
    this.reflectColor = Colors.white,
    this.intensity    = 0.2,
    this.angle        = -0.4,
    this.width        = 0.4,
    this.position     = 0.3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centreX  = size.width  * position;
    final halfW    = size.width  * width / 2;
    final halfH    = size.height * 0.8;

    final rect = Rect.fromCenter(
      center: Offset(centreX, size.height * 0.35),
      width:  halfW  * 2,
      height: halfH  * 2,
    );

    canvas.save();
    canvas.translate(centreX, size.height * 0.35);
    canvas.rotate(angle);
    canvas.translate(-centreX, -size.height * 0.35);

    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment(
          (position * 2 - 1) * 0.5,
          -0.4,
        ),
        radius: 0.6,
        colors: [
          reflectColor.withAlpha((intensity * 255).round()),
          reflectColor.withAlpha(0),
        ],
      ).createShader(rect);

    canvas.drawOval(rect, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(ReflectionPainter old) =>
      old.intensity  != intensity  ||
      old.angle      != angle      ||
      old.position   != position;
}
