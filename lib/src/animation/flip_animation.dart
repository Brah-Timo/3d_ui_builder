import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// A builder widget that applies a perspective-corrected flip transform to
/// [frontChild] and [backChild] based on [animation].
///
/// As [animation] goes from 0 → 1:
/// - 0.0 → 0.5: [frontChild] rotates from 0° to 90° (disappears at the edge).
/// - 0.5 → 1.0: [backChild] appears at -90° and rotates to 0°.
///
/// This matches the canonical "card flip" visual where the back face is a
/// mirror image of the front.
///
/// ### Usage
/// ```dart
/// FlipAnimationBuilder(
///   animation: myAnimation,
///   frontChild: FrontWidget(),
///   backChild:  BackWidget(),
///   axis: FlipAxis.y,
/// )
/// ```
class FlipAnimationBuilder extends StatelessWidget {
  final Animation<double> animation;
  final Widget frontChild;
  final Widget backChild;
  final FlipAxis axis;
  final double perspective;

  const FlipAnimationBuilder({
    super.key,
    required this.animation,
    required this.frontChild,
    required this.backChild,
    this.axis        = FlipAxis.y,
    this.perspective = 0.001,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (ctx, _) {
        final angle      = animation.value * math.pi;
        final showFront  = angle <= math.pi / 2;

        double displayAngle;
        Widget child;

        if (showFront) {
          displayAngle = angle;
          child        = frontChild;
        } else {
          // Back face: continue past 90°, but flip its local coordinates
          // so it reads correctly (not mirrored)
          displayAngle = angle - math.pi;
          child        = backChild;
        }

        final m = Matrix4.identity()..setEntry(3, 2, perspective);
        switch (axis) {
          case FlipAxis.y:
            m.rotateY(displayAngle);
          case FlipAxis.x:
            m.rotateX(displayAngle);
        }

        return Transform(
          alignment: Alignment.center,
          transform: m,
          child: child,
        );
      },
    );
  }
}

/// Axis for the flip animation.
enum FlipAxis { x, y }
