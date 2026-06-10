import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

import 'quaternion.dart';
import 'vector3.dart';

/// Extension methods on Flutter's [Matrix4] that simplify common 3-D
/// operations needed by the widget layer.
///
/// All factory helpers return a fresh [Matrix4]; none of the extension methods
/// mutate the receiver unless the name ends with `Set`.
extension Matrix4Ext on Matrix4 {
  // ─── Factory-style builders ────────────────────────────────────────────────

  /// Returns a perspective-projection matrix.
  ///
  /// [fovYRadians] is the vertical field-of-view angle (radians).
  /// [aspectRatio] is width / height.
  /// [near] and [far] are the clipping plane distances.
  static Matrix4 perspective({
    double fovYRadians = math.pi / 4,
    double aspectRatio = 1.0,
    double near = 0.1,
    double far = 1000.0,
  }) {
    final yScale = 1.0 / math.tan(fovYRadians * 0.5);
    final xScale = yScale / aspectRatio;
    final nf     = 1.0 / (near - far);

    return Matrix4.fromList([
      xScale, 0,      0,                       0,
      0,      yScale, 0,                       0,
      0,      0,      (far + near) * nf,       -1,
      0,      0,      2.0 * far * near * nf,   0,
    ]);
  }

  /// Returns a translation matrix.
  static Matrix4 translation(Vec3 v) =>
      Matrix4.translation(v.toVmVector3());

  /// Returns a rotation matrix from a [Quat].
  static Matrix4 rotation(Quat q) {
    final n  = q.normalized;
    final xx = n.x * n.x * 2, yy = n.y * n.y * 2, zz = n.z * n.z * 2;
    final xy = n.x * n.y * 2, xz = n.x * n.z * 2, yz = n.y * n.z * 2;
    final wx = n.w * n.x * 2, wy = n.w * n.y * 2, wz = n.w * n.z * 2;

    return Matrix4.fromList([
      1 - yy - zz,  xy + wz,      xz - wy,      0,
      xy - wz,      1 - xx - zz,  yz + wx,      0,
      xz + wy,      yz - wx,      1 - xx - yy,  0,
      0,            0,            0,             1,
    ]);
  }

  /// Returns a scale matrix.
  static Matrix4 scaleVec(Vec3 s) =>
      Matrix4.diagonal3Values(s.x, s.y, s.z);

  /// Builds a TRS (Translation × Rotation × Scale) matrix.
  static Matrix4 trs(Vec3 t, Quat r, Vec3 s) {
    final result = rotation(r);
    result.scale(s.x, s.y, s.z);
    result.setTranslation(t.toVmVector3());
    return result;
  }

  // ─── Convenience getters ───────────────────────────────────────────────────

  /// Extracts the translation component.
  Vec3 get translationVec3 {
    final v = getTranslation();
    return Vec3(v.x, v.y, v.z);
  }

  // ─── Perspective helper ───────────────────────────────────────────────────

  /// Adds a perspective entry so Flutter's [Transform] widget renders depth.
  ///
  /// [depth] controls the "focal length" in logical pixels.
  /// A value of 800 matches a typical mobile viewport.
  Matrix4 withPerspective([double depth = 800]) {
    final copy = Matrix4.copy(this);
    copy.setEntry(3, 2, 1.0 / depth);
    return copy;
  }

  /// Applies the perspective entry in-place.
  void applyPerspective([double depth = 800]) =>
      setEntry(3, 2, 1.0 / depth);
}

/// Convenience extensions on [Vec3] to convert to/from [vector_math] types.
extension Vec3VectorMathExt on Vec3 {
  /// Converts to a [vector_math] [vm.Vector3] for use with [Matrix4] methods.
  vm.Vector3 toVmVector3() => vm.Vector3(x, y, z);
}

/// Converts a [vector_math] [vm.Vector3] back to our [Vec3].
extension Vector3ToVec3 on vm.Vector3 {
  Vec3 toVec3() => Vec3(x, y, z);
}
