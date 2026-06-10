import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A card that flips between a front and back face with a true perspective-
/// corrected 3-D rotation animation.
///
/// The rotation uses Flutter's [Matrix4] perspective entry so the far edge
/// appears smaller than the near edge throughout the turn.
///
/// Tapping the card toggles the flip.  An external [FlipCard3DController] can
/// trigger the flip programmatically.
///
/// ### Usage
/// ```dart
/// FlipCard3D(
///   front: ProfileFront(),
///   back:  ProfileBack(),
///   flipDuration: Duration(milliseconds: 600),
///   flipAxis: FlipAxis.y,
///   onFlipComplete: (isFront) => print('Showing front: $isFront'),
/// )
/// ```
class FlipCard3D extends StatefulWidget {
  /// Widget shown when the card faces the viewer.
  final Widget front;

  /// Widget shown when the card is flipped away.
  final Widget back;

  /// Duration of the flip animation.
  final Duration flipDuration;

  /// Flip axis.  [FlipAxis.y] is the horizontal card-turn; [FlipAxis.x] is a
  /// vertical top-to-bottom tumble.
  final FlipAxis flipAxis;

  /// Animation curve applied to the flip.
  final Curve curve;

  /// Whether to start in the flipped (back-showing) state.
  final bool initiallyFlipped;

  /// Perspective coefficient — controls how dramatic the 3-D effect is.
  /// Recommended range: [0.0005, 0.002].
  final double perspective;

  /// Called when the animation completes.  [isFront] is `true` if the front
  /// face is now visible.
  final ValueChanged<bool>? onFlipComplete;

  /// Programmatic control.
  final FlipCard3DController? controller;

  const FlipCard3D({
    super.key,
    required this.front,
    required this.back,
    this.flipDuration    = const Duration(milliseconds: 500),
    this.flipAxis        = FlipAxis.y,
    this.curve           = Curves.easeInOut,
    this.initiallyFlipped = false,
    this.perspective     = 0.001,
    this.onFlipComplete,
    this.controller,
  });

  @override
  State<FlipCard3D> createState() => FlipCard3DState();
}

class FlipCard3DState extends State<FlipCard3D>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: widget.flipDuration,
    value: widget.initiallyFlipped ? 1.0 : 0.0,
  );

  late final Animation<double> _anim = CurvedAnimation(
    parent: _ctrl,
    curve: widget.curve,
  );

  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _isFront = !widget.initiallyFlipped;
    widget.controller?._bind(this);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // ─── Public API (also used by controller) ─────────────────────────────────

  /// Flips the card to show the opposite face.
  void flip() {
    if (_ctrl.isAnimating) return;
    if (_isFront) {
      _ctrl.forward().then((_) {
        if (mounted) {
          setState(() => _isFront = false);
          widget.onFlipComplete?.call(false);
        }
      });
    } else {
      _ctrl.reverse().then((_) {
        if (mounted) {
          setState(() => _isFront = true);
          widget.onFlipComplete?.call(true);
        }
      });
    }
  }

  /// Shows the front face (no-op if already showing).
  void showFront() {
    if (_isFront || _ctrl.isAnimating) return;
    flip();
  }

  /// Shows the back face (no-op if already showing).
  void showBack() {
    if (!_isFront || _ctrl.isAnimating) return;
    flip();
  }

  bool get isFront => _isFront;

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: flip,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (ctx, _) {
          final angle = _anim.value * math.pi;
          final isShowingFront = angle < (math.pi / 2);

          // The back widget must be pre-mirrored so it reads correctly
          final Widget child = isShowingFront ? widget.front : widget.back;

          double rotateAngle;
          if (isShowingFront) {
            rotateAngle = angle;
          } else {
            // Mirror: continue from π, but the back face was already mirrored
            rotateAngle = angle - math.pi;
          }

          Matrix4 m = Matrix4.identity()..setEntry(3, 2, widget.perspective);

          switch (widget.flipAxis) {
            case FlipAxis.y:
              m.rotateY(rotateAngle);
            case FlipAxis.x:
              m.rotateX(rotateAngle);
            case FlipAxis.z:
              m.rotateZ(rotateAngle);
          }

          return Transform(
            alignment: Alignment.center,
            transform: m,
            child: child,
          );
        },
      ),
    );
  }
}

// ─── Controller ───────────────────────────────────────────────────────────────

/// Programmatic control handle for [FlipCard3D].
///
/// ```dart
/// final controller = FlipCard3DController();
///
/// // Somewhere in your widget:
/// FlipCard3D(controller: controller, front: ..., back: ...)
///
/// // Trigger from a button or timer:
/// controller.flip();
/// controller.showFront();
/// ```
class FlipCard3DController {
  FlipCard3DState? _state;

  void _bind(FlipCard3DState state) => _state = state;

  /// Flips to the opposite face.
  void flip() => _state?.flip();

  /// Animates to the front face.
  void showFront() => _state?.showFront();

  /// Animates to the back face.
  void showBack() => _state?.showBack();

  /// Whether the front face is currently visible (approximately).
  bool get isFront => _state?.isFront ?? true;
}

// ─── Enums ────────────────────────────────────────────────────────────────────

/// The rotation axis used by [FlipCard3D].
enum FlipAxis { x, y, z }
