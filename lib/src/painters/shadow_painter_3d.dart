import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/math/vector3.dart';
import '../widgets/scene/light_source.dart';

/// A [CustomPainter] that draws a dynamic contact shadow on the ground plane
/// beneath a 3-D object.
///
/// The shadow shape, offset, and blur are all computed from a [LightSource],
/// so the shadow moves realistically as the light position changes.
///
/// ### Usage
/// ```dart
/// CustomPaint(
///   painter: ShadowPainter3D(
///     objectPosition: Vec3(0, 0, 0),
///     light: LightSource.point(position: Vec3(-200, -300, 400)),
///     shadowColor: Colors.black54,
///     blurRadius: 24,
///   ),
///   child: MyWidget(),
/// )
/// ```
class ShadowPainter3D extends CustomPainter {
  final Vec3        objectPosition;
  final LightSource light;
  final Color       shadowColor;
  final double      blurRadius;
  final double      shadowScale;

  const ShadowPainter3D({
    required this.objectPosition,
    required this.light,
    this.shadowColor = const Color(0x55000000),
    this.blurRadius  = 20,
    this.shadowScale = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Offset shadowOffset;
    double blur;
    double opacity;

    switch (light.type) {
      case LightType.ambient:
        // Ambient = no directional shadow
        shadowOffset = Offset.zero;
        blur         = blurRadius * 0.5;
        opacity      = 0.2;

      case LightType.directional:
        final d = light.direction.normalized;
        shadowOffset = Offset(-d.x, -d.y) * 20 * light.intensity;
        blur         = blurRadius;
        opacity      = 0.4 * light.intensity;

      case LightType.point:
        // Compute shadow from point-light geometry
        final toLight = light.position - objectPosition;
        final dist    = toLight.length.clamp(50, 2000);
        final angle   = math.atan2(toLight.x, toLight.z);
        final stretch = dist / light.radius;

        shadowOffset = Offset(
          math.sin(angle) * stretch * 15,
          math.cos(angle) * stretch * 5 + 8,
        );
        blur    = blurRadius * (0.5 + stretch * 0.5);
        opacity = (0.5 * light.intensity * (1 - stretch)).clamp(0.0, 0.6);
    }

    final rx = size.width  / 2 * shadowScale;
    final ry = size.height / 4 * shadowScale;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(
          size.width  / 2 + shadowOffset.dx,
          size.height + shadowOffset.dy,
        ),
        width:  rx * 2,
        height: ry * 2,
      ),
      Paint()
        ..color      = shadowColor.withAlpha((opacity * 255).round())
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur),
    );
  }

  @override
  bool shouldRepaint(ShadowPainter3D old) =>
      old.objectPosition != objectPosition ||
      old.blurRadius     != blurRadius     ||
      old.light.position != light.position;
}
