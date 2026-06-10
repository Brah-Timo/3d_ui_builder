import 'package:flutter/widgets.dart';

import '../core/math/quaternion.dart';
import '../core/math/vector3.dart';

/// An [Animation] subclass that interpolates a rotation angle in radians,
/// returning the result as a [Quat].
///
/// Unlike using a plain `Tween<double>`, this class ensures the interpolation
/// always takes the shortest arc around the sphere via [Quat.slerp].
///
/// ### Usage
/// ```dart
/// final ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 1));
///
/// final anim = RotationAnimation(
///   controller: ctrl,
///   from: Quat.identity,
///   to:   Quat.axisAngle(Vec3.up, math.pi),
///   curve: Curves.easeInOut,
/// );
///
/// // Use in an AnimatedBuilder or listen directly
/// anim.addListener(() => setState(() {}));
/// ctrl.forward();
/// ```
class RotationAnimation extends Animation<Quat>
    with AnimationWithParentMixin<double> {
  final AnimationController controller;

  /// Starting orientation.
  final Quat from;

  /// Ending orientation.
  final Quat to;

  /// Optional curve applied to the raw [controller] value.
  final Curve curve;

  RotationAnimation({
    required this.controller,
    required this.from,
    required this.to,
    this.curve = Curves.linear,
  });

  @override
  Animation<double> get parent => controller;

  @override
  Quat get value {
    final t = curve.transform(controller.value.clamp(0.0, 1.0));
    return Quat.slerp(from, to, t);
  }
}

/// An [Animation] that continuously rotates around [axis] at [radiansPerSecond].
///
/// Attach to a [Ticker] (via an [AnimationController] in repeat mode).
///
/// ```dart
/// final ctrl = AnimationController(
///   vsync: this,
///   duration: const Duration(seconds: 3),
/// )..repeat();
///
/// final spin = ContinuousRotationAnimation(
///   controller: ctrl,
///   axis: Vec3.up,
/// );
/// ```
class ContinuousRotationAnimation extends Animation<Quat>
    with AnimationWithParentMixin<double> {
  final AnimationController controller;

  /// The axis to rotate around.
  final Vec3 axis;

  /// Total radians to rotate per second (default = one full revolution / 3 s).
  final double radiansPerSecond;

  ContinuousRotationAnimation({
    required this.controller,
    required this.axis,
    this.radiansPerSecond = 2.09,   // ≈ 2π / 3
  });

  @override
  Animation<double> get parent => controller;

  @override
  Quat get value {
    final totalAngle = controller.value * radiansPerSecond *
        controller.duration!.inMicroseconds / 1000000;
    return Quat.axisAngle(axis.normalized, totalAngle);
  }
}
