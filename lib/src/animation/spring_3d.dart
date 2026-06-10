import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

import '../core/math/transform3d.dart';

/// Produces a physics-based spring animation between two [Transform3D] values.
///
/// The spring is defined by [stiffness] (how tight) and [damping] (how quickly
/// it settles).  These correspond directly to [SpringDescription.stiffness]
/// and [SpringDescription.damping].
///
/// **Typical presets:**
/// | Feel       | stiffness | damping |
/// |------------|-----------|---------|
/// | Snappy     | 500       | 30      |
/// | Bouncy     | 200       | 10      |
/// | Gentle     | 100       | 18      |
/// | Over-damp  | 200       | 40      |
///
/// ### Usage
/// ```dart
/// final spring = Spring3D(stiffness: 300, damping: 22);
///
/// final anim = spring.animate(
///   controller: _ctrl,
///   from: initialTransform,
///   to:   targetTransform,
/// );
///
/// AnimatedBuilder(
///   animation: anim,
///   builder: (ctx, child) => Transform(
///     transform: anim.value.toMatrix4Perspective(),
///     alignment: Alignment.center,
///     child: child,
///   ),
///   child: MyWidget(),
/// )
/// ```
class Spring3D {
  final double stiffness;
  final double damping;

  const Spring3D({
    this.stiffness = 200,
    this.damping   = 20,
  });

  // ─── Presets ───────────────────────────────────────────────────────────────

  static const Spring3D snappy  = Spring3D(stiffness: 500, damping: 30);
  static const Spring3D bouncy  = Spring3D(stiffness: 200, damping: 10);
  static const Spring3D gentle  = Spring3D(stiffness: 100, damping: 18);
  static const Spring3D stiff   = Spring3D(stiffness: 800, damping: 60);

  // ─── Factory ──────────────────────────────────────────────────────────────

  /// Returns an [Animation<Transform3D>] driven by [controller] that springs
  /// from [from] to [to].
  Animation<Transform3D> animate({
    required AnimationController controller,
    required Transform3D from,
    required Transform3D to,
  }) {
    return _Spring3DAnimation(
      controller: controller,
      from:       from,
      to:         to,
      description: SpringDescription(
        mass:      1,
        stiffness: stiffness,
        damping:   damping,
      ),
    );
  }
}

// ─── Private animation ────────────────────────────────────────────────────────

class _Spring3DAnimation extends Animation<Transform3D>
    with AnimationWithParentMixin<double> {
  final AnimationController controller;
  final Transform3D from;
  final Transform3D to;
  final SpringDescription description;

  _Spring3DAnimation({
    required this.controller,
    required this.from,
    required this.to,
    required this.description,
  });

  @override
  Animation<double> get parent => controller;

  @override
  Transform3D get value {
    // Map the raw controller value [0..1] through a spring simulation
    final sim = SpringSimulation(description, 0, 1, 0);
    final t   = sim.x(controller.value).clamp(0.0, 1.0);
    return from.lerp(to, t);
  }
}

// ─── Convenience widget ───────────────────────────────────────────────────────

/// A convenience widget that plays a spring animation whenever [targetTransform]
/// changes.
///
/// ```dart
/// SpringTransform3D(
///   targetTransform: _dragTransform,
///   spring: Spring3D.bouncy,
///   child: MyCard(),
/// )
/// ```
class SpringTransform3D extends StatefulWidget {
  final Transform3D targetTransform;
  final Spring3D    spring;
  final Widget      child;
  final double      perspective;

  const SpringTransform3D({
    super.key,
    required this.targetTransform,
    required this.child,
    this.spring      = Spring3D.gentle,
    this.perspective = 800,
  });

  @override
  State<SpringTransform3D> createState() => _SpringTransform3DState();
}

class _SpringTransform3DState extends State<SpringTransform3D>
    with SingleTickerProviderStateMixin {
  // Eagerly initialised in initState() so dispose() never triggers
  // the lazy initialiser on a deactivated element.
  late AnimationController _ctrl;

  Transform3D _fromTransform = Transform3D.identity;
  Animation<Transform3D>? _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void didUpdateWidget(SpringTransform3D old) {
    super.didUpdateWidget(old);
    if (old.targetTransform != widget.targetTransform) {
      _fromTransform = _anim?.value ?? _fromTransform;
      _anim = widget.spring.animate(
        controller: _ctrl,
        from:       _fromTransform,
        to:         widget.targetTransform,
      );
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveAnim = _anim;
    if (effectiveAnim == null) {
      return Transform(
        alignment: Alignment.center,
        transform: widget.targetTransform.toMatrix4Perspective(widget.perspective),
        child: widget.child,
      );
    }

    return AnimatedBuilder(
      animation: effectiveAnim,
      builder: (ctx, child) => Transform(
        alignment: Alignment.center,
        transform: effectiveAnim.value.toMatrix4Perspective(widget.perspective),
        child: child,
      ),
      child: widget.child,
    );
  }
}
