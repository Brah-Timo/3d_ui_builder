import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'matrix4_ext.dart';
import 'quaternion.dart';
import 'vector3.dart';

/// Represents a full 3-D transform: position, rotation, and non-uniform scale.
///
/// [Transform3D] is the core value type used throughout [three_d_ui_builder].
/// It is immutable, hashable, and safe to compare with `==`.
///
/// It is designed to slot directly into Flutter's animation framework via
/// [Transform3DTween] and [Transform3DAnimation].
///
/// ### Example
/// ```dart
/// final initial = Transform3D.identity;
///
/// final rotated = initial.copyWith(
///   rotation: Quat.axisAngle(Vec3.up, math.pi / 4),
/// );
///
/// // Build a Flutter Transform widget matrix
/// Transform(
///   transform: rotated.toMatrix4(),
///   alignment: Alignment.center,
///   child: MyWidget(),
/// )
/// ```
@immutable
final class Transform3D {
  /// World position in logical pixels (x = right, y = down, z = towards viewer).
  final Vec3 position;

  /// Rotation represented as a unit quaternion (avoids Gimbal Lock).
  final Quat rotation;

  /// Per-axis scale factor (1.0 = original size on each axis).
  final Vec3 scale;

  // ─── Constructors ──────────────────────────────────────────────────────────

  const Transform3D({
    required this.position,
    required this.rotation,
    required this.scale,
  });

  // ─── Named constructors ────────────────────────────────────────────────────

  /// The neutral transform: at origin, no rotation, full scale.
  static const Transform3D identity = Transform3D(
    position: Vec3.zero,
    rotation: Quat.identity,
    scale:    Vec3.one,
  );

  /// Creates a transform with only a translation offset.
  const Transform3D.translated(Vec3 offset)
      : position = offset,
        rotation = Quat.identity,
        scale    = Vec3.one;

  /// Creates a transform with only a rotation.
  const Transform3D.rotated(Quat q)
      : position = Vec3.zero,
        rotation = q,
        scale    = Vec3.one;

  /// Creates a transform with only a uniform scale factor.
  Transform3D.scaled(double factor)
      : position = Vec3.zero,
        rotation = Quat.identity,
        scale    = Vec3.all(factor);

  // ─── Matrix conversion ─────────────────────────────────────────────────────

  /// Converts to a [Matrix4] suitable for Flutter's [Transform] widget.
  ///
  /// The perspective entry is NOT applied here — call [toMatrix4Perspective]
  /// if you need it, or add it externally via [Matrix4Ext.withPerspective].
  Matrix4 toMatrix4() => Matrix4Ext.trs(position, rotation, scale);

  /// Same as [toMatrix4] but with a perspective entry applied at [depth].
  ///
  /// [depth] is the "focal length" in logical pixels.
  Matrix4 toMatrix4Perspective([double depth = 800]) =>
      toMatrix4().withPerspective(depth);

  // ─── Interpolation ─────────────────────────────────────────────────────────

  /// Linear-interpolates position and scale; uses SLERP for rotation.
  ///
  /// [t] should be in the range [0.0, 1.0].
  Transform3D lerp(Transform3D other, double t) {
    if (t <= 0.0) return this;
    if (t >= 1.0) return other;
    return Transform3D(
      position: position.lerp(other.position, t),
      rotation: Quat.slerp(rotation, other.rotation, t),
      scale:    scale.lerp(other.scale, t),
    );
  }

  // ─── Composition ───────────────────────────────────────────────────────────

  /// Returns a new [Transform3D] with [other] applied on top of [this].
  Transform3D compose(Transform3D other) => Transform3D(
        position: position + rotation.rotate(Vec3(
          other.position.x * scale.x,
          other.position.y * scale.y,
          other.position.z * scale.z,
        )),
        rotation: rotation * other.rotation,
        scale:    Vec3(scale.x * other.scale.x,
                       scale.y * other.scale.y,
                       scale.z * other.scale.z),
      );

  // ─── copyWith ──────────────────────────────────────────────────────────────

  Transform3D copyWith({
    Vec3? position,
    Quat? rotation,
    Vec3? scale,
  }) =>
      Transform3D(
        position: position ?? this.position,
        rotation: rotation ?? this.rotation,
        scale:    scale    ?? this.scale,
      );

  // ─── Equality ──────────────────────────────────────────────────────────────

  @override
  bool operator ==(Object other) =>
      other is Transform3D &&
      position == other.position &&
      rotation == other.rotation &&
      scale    == other.scale;

  @override
  int get hashCode => Object.hash(position, rotation, scale);

  @override
  String toString() =>
      'Transform3D(pos=$position, rot=$rotation, scale=$scale)';
}

// ─── Tween ─────────────────────────────────────────────────────────────────

/// A [Tween] that interpolates between two [Transform3D] values.
///
/// Plugs directly into Flutter's animation framework:
/// ```dart
/// final tween = Transform3DTween(
///   begin: Transform3D.identity,
///   end: Transform3D(
///     position: const Vec3(0, -50, 0),
///     rotation: Quat.axisAngle(Vec3.forward, math.pi / 2),
///     scale:    Vec3.one,
///   ),
/// );
/// ```
class Transform3DTween extends Tween<Transform3D> {
  Transform3DTween({super.begin, super.end});

  @override
  Transform3D lerp(double t) {
    final b = begin ?? Transform3D.identity;
    final e = end   ?? Transform3D.identity;
    return b.lerp(e, t);
  }
}
