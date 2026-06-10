import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../core/math/vector3.dart';

/// A collection of pure-function helpers for perspective calculations used
/// throughout the widget and painter layers.
abstract final class PerspectiveUtils {
  PerspectiveUtils._();

  // ─── Projection ────────────────────────────────────────────────────────────

  /// Projects a 3-D world-space point to 2-D screen space.
  ///
  /// [focalLength] is the distance from the virtual camera to the projection
  /// plane (logical pixels).  A larger value = less dramatic perspective.
  static Offset project(
    Vec3 point, {
    Offset screenCentre = Offset.zero,
    double focalLength  = 800,
  }) {
    final scale = focalLength / (focalLength + point.z);
    return Offset(
      screenCentre.dx + point.x * scale,
      screenCentre.dy + point.y * scale,
    );
  }

  /// Returns the uniform scale factor for an object at depth [z].
  static double depthScale(double z, {double focalLength = 800}) =>
      focalLength / (focalLength + z);

  /// Returns a normalised depth in [0, 1] where 1 = closest to camera.
  static double normaliseDepth(
    double z, {
    double nearPlane = -400,
    double farPlane  =  400,
  }) =>
      ((z - nearPlane) / (farPlane - nearPlane)).clamp(0.0, 1.0);

  // ─── Tilt helpers ──────────────────────────────────────────────────────────

  /// Converts a normalised pointer offset ([-1, 1]) and a max tilt angle in
  /// degrees to a perspective-enabled [Matrix4].
  static Matrix4 tiltMatrix(
    Offset normOffset,
    double maxTiltDeg, {
    double perspectiveCoeff = 0.001,
  }) {
    final radX = -normOffset.dy * maxTiltDeg * math.pi / 180;
    final radY =  normOffset.dx * maxTiltDeg * math.pi / 180;
    return Matrix4.identity()
      ..setEntry(3, 2, perspectiveCoeff)
      ..rotateX(radX)
      ..rotateY(radY);
  }

  // ─── Arc helpers ───────────────────────────────────────────────────────────

  /// Evenly spaces [count] points around a circle of [radius] at elevation [y].
  static List<Vec3> circlePoints({
    required int    count,
    required double radius,
    double          y     = 0,
    double          phase = 0,
  }) =>
      List.generate(count, (i) {
        final angle = phase + i * 2 * math.pi / count;
        return Vec3(math.sin(angle) * radius, y, math.cos(angle) * radius);
      });

  /// Evenly spaces [count] points on a sphere of [radius] using the
  /// Fibonacci lattice.
  static List<Vec3> spherePoints({
    required int    count,
    required double radius,
  }) {
    final golden = (1 + math.sqrt(5)) / 2;
    return List.generate(count, (i) {
      final theta = math.acos(1 - 2 * (i + 0.5) / count);
      final phi   = 2 * math.pi * i / golden;
      return Vec3(
        math.sin(theta) * math.cos(phi) * radius,
        math.cos(theta) * radius,
        math.sin(theta) * math.sin(phi) * radius,
      );
    });
  }

  // ─── Colour helpers ────────────────────────────────────────────────────────

  /// Darkens [color] by [amount] (0 → no change, 1 → black).
  static Color darken(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  /// Lightens [color] by [amount].
  static Color lighten(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }
}
