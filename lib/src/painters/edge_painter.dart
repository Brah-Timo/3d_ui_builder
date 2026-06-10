import 'package:flutter/material.dart';

/// A [CustomPainter] that draws the visible edges of a 3-D wireframe polygon,
/// projected onto 2-D using a simple perspective transform.
///
/// Pass a list of 3-D vertices (closed polygon) and a rotation transform.
/// The painter projects each vertex and connects them with anti-aliased lines.
///
/// Useful for debug overlays, sci-fi HUD frames, and architectural wireframes.
///
/// ### Usage
/// ```dart
/// CustomPaint(
///   painter: EdgePainter(
///     vertices: [
///       Vec3(-50, -50, 0), Vec3(50, -50, 0),
///       Vec3(50,  50, 0),  Vec3(-50, 50, 0),
///     ],
///     color:       Colors.cyanAccent,
///     strokeWidth: 1.5,
///     focalLength: 600,
///   ),
/// )
/// ```
class EdgePainter extends CustomPainter {
  final List<({double x, double y, double z})> vertices;
  final Color       color;
  final double      strokeWidth;
  final double      focalLength;
  final bool        closed;

  const EdgePainter({
    required this.vertices,
    this.color       = const Color(0xFF00FFFF),
    this.strokeWidth = 1.5,
    this.focalLength = 600,
    this.closed      = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (vertices.length < 2) return;

    final centre = Offset(size.width / 2, size.height / 2);
    final paint  = Paint()
      ..color       = color
      ..strokeWidth = strokeWidth
      ..style       = PaintingStyle.stroke
      ..strokeCap   = StrokeCap.round
      ..isAntiAlias = true;

    final projected = vertices.map((v) => _project(v, centre)).toList();

    final path = Path()..moveTo(projected.first.dx, projected.first.dy);
    for (int i = 1; i < projected.length; i++) {
      path.lineTo(projected[i].dx, projected[i].dy);
    }
    if (closed) path.close();

    canvas.drawPath(path, paint);
  }

  Offset _project(({double x, double y, double z}) v, Offset centre) {
    final scale = focalLength / (focalLength + v.z);
    return Offset(centre.dx + v.x * scale, centre.dy + v.y * scale);
  }

  @override
  bool shouldRepaint(EdgePainter old) =>
      old.vertices    != vertices    ||
      old.color       != color       ||
      old.focalLength != focalLength;
}
