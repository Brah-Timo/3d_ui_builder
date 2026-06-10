import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

import '../math/vector3.dart';

/// Provides helpers that bridge Flutter's 2-D [Canvas] with the perspective
/// transforms needed by 3-D widgets.
///
/// These utilities are used internally by the painters layer and the widget
/// layer.  Most application code will not need to call them directly.
abstract final class CanvasBridge {
  CanvasBridge._();

  // ─── Projection ────────────────────────────────────────────────────────────

  /// Projects a 3-D world-space point to a 2-D screen point using a simple
  /// perspective projection.
  ///
  /// [focalLength] is the distance from the camera to the projection plane in
  /// logical pixels (800 is a comfortable default for mobile).
  static Offset project(
    Vec3 point, {
    Offset origin = Offset.zero,
    double focalLength = 800,
  }) {
    if (point.z <= -focalLength) {
      // Behind the camera — project to infinity
      return Offset(double.maxFinite, double.maxFinite);
    }
    final scale = focalLength / (focalLength + point.z);
    return Offset(
      origin.dx + point.x * scale,
      origin.dy + point.y * scale,
    );
  }

  /// Returns the apparent scale factor for an object at depth [z], given a
  /// camera at the origin with focal length [focalLength].
  static double scaleAtDepth(double z, {double focalLength = 800}) {
    if (z <= -focalLength) return 0;
    return focalLength / (focalLength + z);
  }

  // ─── Canvas helpers ────────────────────────────────────────────────────────

  /// Saves the canvas state, applies [matrix4], executes [draw], then restores.
  static void withTransform(
    Canvas canvas,
    Matrix4 matrix4,
    void Function(Canvas) draw,
  ) {
    canvas.save();
    canvas.transform(matrix4.storage);
    draw(canvas);
    canvas.restore();
  }

  /// Draws an anti-aliased line between two 3-D world points projected onto
  /// the canvas.
  static void drawLine3D(
    Canvas canvas,
    Paint paint,
    Vec3 from,
    Vec3 to, {
    Offset origin = Offset.zero,
    double focalLength = 800,
  }) {
    final p1 = project(from, origin: origin, focalLength: focalLength);
    final p2 = project(to,   origin: origin, focalLength: focalLength);
    canvas.drawLine(p1, p2, paint);
  }

  // ─── Layout helpers ────────────────────────────────────────────────────────

  /// Returns the [Matrix4] that, when set on a [Transform] widget, makes a
  /// child appear to face the camera even as a parent rotates.
  ///
  /// Useful for labels and overlays that should always be readable.
  static Matrix4 billboardMatrix(Matrix4 parentRotation) {
    // Extract the 3×3 rotation sub-matrix and invert it
    final inv = Matrix4.inverted(parentRotation);
    // Clear translation
    inv.setTranslation(vm.Vector3.zero());
    return inv;
  }

  // ─── Depth helpers ─────────────────────────────────────────────────────────

  /// Returns a normalised depth in [0, 1] where 0 = far and 1 = close.
  ///
  /// Useful for computing opacity and scale of list items.
  static double normaliseDepth(
    double z, {
    double minZ = -300,
    double maxZ = 300,
  }) =>
      ((z - minZ) / (maxZ - minZ)).clamp(0.0, 1.0);
}
