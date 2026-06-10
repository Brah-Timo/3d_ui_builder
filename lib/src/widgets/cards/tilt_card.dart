import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// A card that tilts to follow either finger drag or the device gyroscope,
/// creating a genuine parallax depth illusion.
///
/// Two tilt sources are available, controllable via [tiltSource]:
///
/// - [TiltSource.pointer] — the card tilts as the user moves their finger
///   across it (works on all platforms).
/// - [TiltSource.gyroscope] — the card tilts with the physical device
///   orientation (mobile only; requires `sensors_plus` permission).
///
/// A configurable [parallaxLayers] list allows multiple children to move at
/// different depths, making foreground elements appear to float above the card.
///
/// ### Usage
/// ```dart
/// TiltCard(
///   tiltSource: TiltSource.pointer,
///   maxTilt: 18,
///   parallaxLayers: [
///     ParallaxLayer(depth: 0.0, child: CardBackground()),
///     ParallaxLayer(depth: 0.5, child: CardTitle()),
///     ParallaxLayer(depth: 1.0, child: CardBadge()),
///   ],
/// )
/// ```
class TiltCard extends StatefulWidget {
  /// The source of tilt data.
  final TiltSource tiltSource;

  /// Maximum tilt angle in degrees on each axis.
  final double maxTilt;

  /// How quickly the card snaps back when the pointer leaves.  0 = instant.
  final Duration returnDuration;

  /// Perspective coefficient for the tilt transform.
  final double perspective;

  /// The card's background decoration.
  final BoxDecoration decoration;

  /// Parallax layers rendered from bottom (index 0) to top.
  final List<ParallaxLayer> parallaxLayers;

  /// Multiplier applied to gyroscope readings when [tiltSource] is
  /// [TiltSource.gyroscope].
  final double gyroSensitivity;

  const TiltCard({
    super.key,
    this.tiltSource     = TiltSource.pointer,
    this.maxTilt        = 20.0,
    this.returnDuration = const Duration(milliseconds: 400),
    this.perspective    = 0.001,
    this.decoration     = const BoxDecoration(
      color:       Color(0xFF1E1E2E),
      borderRadius: BorderRadius.all(Radius.circular(20)),
    ),
    this.parallaxLayers = const [],
    this.gyroSensitivity = 8.0,
  });

  @override
  State<TiltCard> createState() => _TiltCardState();
}

class _TiltCardState extends State<TiltCard>
    with SingleTickerProviderStateMixin {
  double _tiltX = 0;   // degrees
  double _tiltY = 0;

  // Return-to-zero animation
  late final AnimationController _returnCtrl = AnimationController(
    vsync: this,
    duration: widget.returnDuration,
  );
  late Animation<double> _returnX = const AlwaysStoppedAnimation(0);
  late Animation<double> _returnY = const AlwaysStoppedAnimation(0);

  // Gyroscope stream
  StreamSubscription<GyroscopeEvent>? _gyroSub;

  // Pointer tracking
  Size _cardSize = Size.zero;

  @override
  void initState() {
    super.initState();
    if (widget.tiltSource == TiltSource.gyroscope) {
      _startGyroscope();
    }
  }

  @override
  void didUpdateWidget(TiltCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tiltSource != widget.tiltSource) {
      _gyroSub?.cancel();
      _gyroSub = null;
      if (widget.tiltSource == TiltSource.gyroscope) _startGyroscope();
    }
  }

  @override
  void dispose() {
    _returnCtrl.dispose();
    _gyroSub?.cancel();
    super.dispose();
  }

  // ─── Gyroscope ────────────────────────────────────────────────────────────

  void _startGyroscope() {
    _gyroSub = gyroscopeEventStream().listen((event) {
      if (!mounted) return;
      setState(() {
        // Gyro x-rate tilts card on X; y-rate tilts on Y
        _tiltX = (_tiltX - event.x * widget.gyroSensitivity)
            .clamp(-widget.maxTilt, widget.maxTilt);
        _tiltY = (_tiltY + event.y * widget.gyroSensitivity)
            .clamp(-widget.maxTilt, widget.maxTilt);
      });
    });
  }

  // ─── Pointer ──────────────────────────────────────────────────────────────

  void _onPointerMove(PointerMoveEvent e) {
    if (widget.tiltSource != TiltSource.pointer) return;
    _returnCtrl.stop();
    final centre = Offset(_cardSize.width / 2, _cardSize.height / 2);
    final dx     = (e.localPosition.dx - centre.dx) / (_cardSize.width  / 2);
    final dy     = (e.localPosition.dy - centre.dy) / (_cardSize.height / 2);
    setState(() {
      _tiltX = -dy * widget.maxTilt;
      _tiltY =  dx * widget.maxTilt;
    });
  }

  void _onPointerUp(PointerUpEvent _) => _startReturn();
  void _onPointerCancel(PointerCancelEvent _) => _startReturn();

  void _startReturn() {
    if (widget.tiltSource != TiltSource.pointer) return;
    final fromX = _tiltX;
    final fromY = _tiltY;
    _returnX = Tween<double>(begin: fromX, end: 0).animate(
      CurvedAnimation(parent: _returnCtrl, curve: Curves.elasticOut),
    )..addListener(() {
        if (mounted) setState(() => _tiltX = _returnX.value);
      });
    _returnY = Tween<double>(begin: fromY, end: 0).animate(
      CurvedAnimation(parent: _returnCtrl, curve: Curves.elasticOut),
    )..addListener(() {
        if (mounted) setState(() => _tiltY = _returnY.value);
      });
    _returnCtrl.forward(from: 0);
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerMove:   _onPointerMove,
      onPointerUp:     _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          _cardSize = Size(constraints.maxWidth, constraints.maxHeight);

          final radX = _tiltX * math.pi / 180;
          final radY = _tiltY * math.pi / 180;

          final m = Matrix4.identity()
            ..setEntry(3, 2, widget.perspective)
            ..rotateX(radX)
            ..rotateY(radY);

          return Transform(
            alignment: Alignment.center,
            transform: m,
            child: DecoratedBox(
              decoration: widget.decoration,
              child: ClipRRect(
                borderRadius: widget.decoration.borderRadius
                        ?.resolve(TextDirection.ltr) ??
                    BorderRadius.zero,
                child: Stack(
                  fit: StackFit.expand,
                  children: widget.parallaxLayers
                      .map((layer) => _buildLayer(layer, radX, radY))
                      .toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLayer(ParallaxLayer layer, double radX, double radY) {
    // Shift the layer in 2-D by its depth * tilt angle
    final shift = Offset(
      radY * layer.depth * 20,
      radX * layer.depth * 20,
    );
    return Transform.translate(
      offset: shift,
      child: layer.child,
    );
  }
}

// ─── Supporting types ─────────────────────────────────────────────────────────

/// Controls where tilt data comes from.
enum TiltSource { pointer, gyroscope }

/// A single layer in a [TiltCard] parallax stack.
///
/// [depth] ranges from `0.0` (background — no movement) to `1.0`
/// (foreground — maximum movement).
class ParallaxLayer {
  final double depth;
  final Widget child;

  const ParallaxLayer({required this.depth, required this.child});
}
