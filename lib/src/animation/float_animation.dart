import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// An [Animation<double>] that produces a sinusoidal float value in the range
/// [-[amplitude], +[amplitude]].
///
/// Combine with [Transform.translate] to make a widget bob up and down.
///
/// ### Usage
/// ```dart
/// final ctrl = AnimationController(
///   vsync: this,
///   duration: const Duration(milliseconds: 2000),
/// )..repeat();
///
/// final float = FloatAnimation(controller: ctrl, amplitude: 8.0);
///
/// AnimatedBuilder(
///   animation: float,
///   builder: (ctx, child) => Transform.translate(
///     offset: Offset(0, float.value),
///     child: child,
///   ),
///   child: MyWidget(),
/// )
/// ```
class FloatAnimation extends Animation<double>
    with AnimationWithParentMixin<double> {
  final AnimationController controller;

  /// Peak displacement in logical pixels.
  final double amplitude;

  /// Phase offset in [0, 1] — useful for staggering multiple floaters.
  final double phase;

  FloatAnimation({
    required this.controller,
    this.amplitude = 6.0,
    this.phase     = 0.0,
  });

  @override
  Animation<double> get parent => controller;

  @override
  double get value =>
      math.sin((controller.value + phase) * 2 * math.pi) * amplitude;
}

/// Convenience widget that applies a continuous float animation to [child].
///
/// ```dart
/// Floater(
///   amplitude: 8,
///   period:    Duration(milliseconds: 2200),
///   child:     MyCard(),
/// )
/// ```
class Floater extends StatefulWidget {
  final Widget child;

  /// Peak displacement in logical pixels.
  final double amplitude;

  /// Duration of one complete cycle.
  final Duration period;

  /// Phase offset [0, 1].
  final double phase;

  /// Axis of oscillation.
  final Axis axis;

  const Floater({
    super.key,
    required this.child,
    this.amplitude = 6,
    this.period    = const Duration(milliseconds: 2000),
    this.phase     = 0,
    this.axis      = Axis.vertical,
  });

  @override
  State<Floater> createState() => _FloaterState();
}

class _FloaterState extends State<Floater>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: widget.period,
  )..repeat();

  late final FloatAnimation _float = FloatAnimation(
    controller: _ctrl,
    amplitude:  widget.amplitude,
    phase:      widget.phase,
  );

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _float,
      builder: (ctx, child) {
        final offset = widget.axis == Axis.vertical
            ? Offset(0, _float.value)
            : Offset(_float.value, 0);
        return Transform.translate(offset: offset, child: child);
      },
      child: widget.child,
    );
  }
}
