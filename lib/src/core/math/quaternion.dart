import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'vector3.dart';

/// An immutable unit quaternion that represents a 3D rotation.
///
/// Quaternions avoid the [Gimbal Lock] problem inherent in Euler angles and
/// are numerically stable for interpolation with [slerp].
///
/// The internal representation is `(x, y, z, w)` where `(x, y, z)` is the
/// imaginary/vector part and `w` is the real/scalar part.
///
/// To create a rotation:
/// ```dart
/// // 45° around the Y-axis
/// final rot = Quat.axisAngle(Vec3.right, math.pi / 4);
///
/// // Compose two rotations
/// final combined = rot1 * rot2;
///
/// // Smooth interpolation between two rotations
/// final halfway = Quat.slerp(from, to, 0.5);
/// ```
@immutable
final class Quat {
  final double x;
  final double y;
  final double z;
  final double w;

  // ─── Constructors ──────────────────────────────────────────────────────────

  const Quat(this.x, this.y, this.z, this.w);

  // ─── Named constants ───────────────────────────────────────────────────────

  /// The identity quaternion — represents no rotation.
  static const Quat identity = Quat(0, 0, 0, 1);

  // ─── Factory constructors ──────────────────────────────────────────────────

  /// Creates a rotation of [angleRadians] around the given [axis].
  /// [axis] does not need to be normalised beforehand.
  factory Quat.axisAngle(Vec3 axis, double angleRadians) {
    final n = axis.normalized;
    final half = angleRadians * 0.5;
    final sinHalf = math.sin(half);
    return Quat(
      n.x * sinHalf,
      n.y * sinHalf,
      n.z * sinHalf,
      math.cos(half),
    );
  }

  /// Creates a quaternion from Euler angles (in radians) applied in ZYX order.
  factory Quat.euler(double pitch, double yaw, double roll) {
    final cy = math.cos(yaw * 0.5);
    final sy = math.sin(yaw * 0.5);
    final cp = math.cos(pitch * 0.5);
    final sp = math.sin(pitch * 0.5);
    final cr = math.cos(roll * 0.5);
    final sr = math.sin(roll * 0.5);

    return Quat(
      sr * cp * cy - cr * sp * sy,
      cr * sp * cy + sr * cp * sy,
      cr * cp * sy - sr * sp * cy,
      cr * cp * cy + sr * sp * sy,
    );
  }

  /// Creates a quaternion that rotates [from] direction to [to] direction.
  factory Quat.fromToRotation(Vec3 from, Vec3 to) {
    final f = from.normalized;
    final t = to.normalized;
    final d = f.dot(t);

    if (d >= 1.0 - 1e-10) return Quat.identity;

    if (d <= -1.0 + 1e-10) {
      // 180° rotation — find a perpendicular axis
      var axis = Vec3.right.cross(f);
      if (axis.lengthSquared < 1e-10) axis = Vec3.up.cross(f);
      return Quat.axisAngle(axis.normalized, math.pi);
    }

    final axis = f.cross(t);
    final s = math.sqrt((1.0 + d) * 2.0);
    final inv = 1.0 / s;
    return Quat(axis.x * inv, axis.y * inv, axis.z * inv, s * 0.5).normalized;
  }

  // ─── Computed properties ───────────────────────────────────────────────────

  /// The squared magnitude — avoids sqrt when only comparison is needed.
  double get magnitudeSquared =>
      x * x + y * y + z * z + w * w;

  /// The magnitude of this quaternion (should be ≈ 1 for unit quaternions).
  double get magnitude => math.sqrt(magnitudeSquared);

  /// Returns a normalised copy — always use unit quaternions for rotations.
  Quat get normalized {
    final m = magnitude;
    if (m < 1e-10) return Quat.identity;
    return Quat(x / m, y / m, z / m, w / m);
  }

  /// The conjugate — for unit quaternions this equals the inverse.
  Quat get conjugate => Quat(-x, -y, -z, w);

  /// The inverse rotation.
  Quat get inverse => conjugate.normalized;

  // ─── Arithmetic ────────────────────────────────────────────────────────────

  /// Hamilton product — combines two rotations.
  /// Note: quaternion multiplication is NOT commutative.
  Quat operator *(Quat other) => Quat(
        w * other.x + x * other.w + y * other.z - z * other.y,
        w * other.y - x * other.z + y * other.w + z * other.x,
        w * other.z + x * other.y - y * other.x + z * other.w,
        w * other.w - x * other.x - y * other.y - z * other.z,
      ).normalized;

  // ─── Interpolation ─────────────────────────────────────────────────────────

  /// Spherical linear interpolation between [a] and [b] by factor [t] ∈ [0, 1].
  ///
  /// Produces a constant-speed rotation along the great arc between the two
  /// orientations, avoiding the "squishing" artefact of plain lerp.
  static Quat slerp(Quat a, Quat b, double t) {
    // Clamp t
    final clamped = t.clamp(0.0, 1.0);

    // Dot product — cosine of the angle between quaternions
    double dot = a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w;

    // Ensure shortest path
    Quat end = b;
    if (dot < 0.0) {
      end = Quat(-b.x, -b.y, -b.z, -b.w);
      dot = -dot;
    }

    if (dot > 0.9995) {
      // Numerically close — just lerp and normalise
      return Quat(
        a.x + (end.x - a.x) * clamped,
        a.y + (end.y - a.y) * clamped,
        a.z + (end.z - a.z) * clamped,
        a.w + (end.w - a.w) * clamped,
      ).normalized;
    }

    final theta0 = math.acos(dot.clamp(-1.0, 1.0));
    final theta  = theta0 * clamped;
    final sinT0  = math.sin(theta0);
    final sinT   = math.sin(theta);
    final s1     = sinT / sinT0;
    final s0     = math.cos(theta) - dot * s1;

    return Quat(
      a.x * s0 + end.x * s1,
      a.y * s0 + end.y * s1,
      a.z * s0 + end.z * s1,
      a.w * s0 + end.w * s1,
    ).normalized;
  }

  // ─── Vector rotation ───────────────────────────────────────────────────────

  /// Rotates [v] by this quaternion.
  Vec3 rotate(Vec3 v) {
    final u = Vec3(x, y, z);
    final s = w;
    return u * (2.0 * u.dot(v)) +
        v * (s * s - u.dot(u)) +
        u.cross(v) * (2.0 * s);
  }

  // ─── Decomposition ─────────────────────────────────────────────────────────

  /// Returns the rotation axis and angle (in radians).
  ({Vec3 axis, double angle}) get axisAngle {
    final n = normalized;
    final sinHalfAngle = math.sqrt(1.0 - n.w * n.w);
    if (sinHalfAngle < 1e-10) return (axis: Vec3.forward, angle: 0);
    return (
      axis: Vec3(n.x / sinHalfAngle, n.y / sinHalfAngle, n.z / sinHalfAngle),
      angle: 2.0 * math.acos(n.w.clamp(-1.0, 1.0)),
    );
  }

  // ─── Equality ──────────────────────────────────────────────────────────────

  @override
  bool operator ==(Object other) =>
      other is Quat &&
      x == other.x && y == other.y &&
      z == other.z && w == other.w;

  @override
  int get hashCode => Object.hash(x, y, z, w);

  @override
  String toString() =>
      'Quat(${x.toStringAsFixed(4)}, ${y.toStringAsFixed(4)}, '
      '${z.toStringAsFixed(4)}, ${w.toStringAsFixed(4)})';
}
