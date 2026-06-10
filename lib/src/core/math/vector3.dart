// ignore_for_file: avoid_dynamic_calls
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// A lightweight, immutable 3-component vector used throughout [three_d_ui_builder].
///
/// Wraps [vector_math]'s mutable [Vector3] type in an immutable value object
/// so it can be safely shared across the widget tree and used as a map key.
///
/// All arithmetic operations return new [Vec3] instances — nothing is mutated.
///
/// ```dart
/// const origin = Vec3.zero;
/// final moved  = origin + const Vec3(10, 0, 0);  // Vec3(10, 0, 0)
/// final scaled = moved  * 2;                       // Vec3(20, 0, 0)
/// ```
@immutable
final class Vec3 {
  /// The X component (horizontal axis, positive = right).
  final double x;

  /// The Y component (vertical axis, positive = down in Flutter coordinates).
  final double y;

  /// The Z component (depth axis, positive = towards viewer).
  final double z;

  // ─── Constructors ──────────────────────────────────────────────────────────

  const Vec3(this.x, this.y, this.z);

  /// Creates a [Vec3] where all components are [value].
  const Vec3.all(double value) : this(value, value, value);

  // ─── Named constants ───────────────────────────────────────────────────────

  static const Vec3 zero    = Vec3(0, 0, 0);
  static const Vec3 one     = Vec3(1, 1, 1);
  static const Vec3 right   = Vec3(1, 0, 0);
  static const Vec3 up      = Vec3(0, -1, 0);   // Flutter Y-axis is inverted
  static const Vec3 forward = Vec3(0, 0, 1);
  static const Vec3 left    = Vec3(-1, 0, 0);
  static const Vec3 down    = Vec3(0, 1, 0);
  static const Vec3 back    = Vec3(0, 0, -1);

  // ─── Computed properties ───────────────────────────────────────────────────

  /// The Euclidean length of this vector.
  double get length => math.sqrt(x * x + y * y + z * z);

  /// The squared length — avoids a costly [math.sqrt] when only comparison is needed.
  double get lengthSquared => x * x + y * y + z * z;

  /// Returns a unit vector in the same direction. Returns [Vec3.zero] if length ≈ 0.
  Vec3 get normalized {
    final len = length;
    if (len < 1e-10) return Vec3.zero;
    return Vec3(x / len, y / len, z / len);
  }

  // ─── Arithmetic ────────────────────────────────────────────────────────────

  Vec3 operator +(Vec3 other) => Vec3(x + other.x, y + other.y, z + other.z);
  Vec3 operator -(Vec3 other) => Vec3(x - other.x, y - other.y, z - other.z);
  Vec3 operator -() => Vec3(-x, -y, -z);

  /// Scalar multiplication.
  Vec3 operator *(double scalar) => Vec3(x * scalar, y * scalar, z * scalar);

  /// Scalar division.
  Vec3 operator /(double scalar) {
    assert(scalar != 0, 'Vec3 division by zero');
    return Vec3(x / scalar, y / scalar, z / scalar);
  }

  // ─── Vector operations ─────────────────────────────────────────────────────

  /// Returns the dot product of [this] and [other].
  double dot(Vec3 other) => x * other.x + y * other.y + z * other.z;

  /// Returns the cross product of [this] and [other].
  Vec3 cross(Vec3 other) => Vec3(
        y * other.z - z * other.y,
        z * other.x - x * other.z,
        x * other.y - y * other.x,
      );

  /// Linearly interpolates between [this] and [other] by factor [t] ∈ [0, 1].
  Vec3 lerp(Vec3 other, double t) => Vec3(
        x + (other.x - x) * t,
        y + (other.y - y) * t,
        z + (other.z - z) * t,
      );

  /// Returns the Euclidean distance to [other].
  double distanceTo(Vec3 other) => (this - other).length;

  /// Returns a copy with individual components replaced.
  Vec3 copyWith({double? x, double? y, double? z}) =>
      Vec3(x ?? this.x, y ?? this.y, z ?? this.z);

  /// Clamps every component to [[min], [max]].
  Vec3 clamp(double min, double max) => Vec3(
        x.clamp(min, max),
        y.clamp(min, max),
        z.clamp(min, max),
      );

  /// Reflects this vector around [normal].
  Vec3 reflect(Vec3 normal) => this - normal * (2.0 * dot(normal));

  // ─── Comparison & equality ─────────────────────────────────────────────────

  @override
  bool operator ==(Object other) =>
      other is Vec3 && x == other.x && y == other.y && z == other.z;

  @override
  int get hashCode => Object.hash(x, y, z);

  @override
  String toString() =>
      'Vec3(${x.toStringAsFixed(3)}, ${y.toStringAsFixed(3)}, ${z.toStringAsFixed(3)})';
}
