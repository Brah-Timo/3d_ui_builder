import 'dart:math' as math;

import 'package:flutter/material.dart';

/// An icon button that rotates 360° around its vertical axis on each tap,
/// with a 3-D depth slab and a subtle wobble on hover.
///
/// ### Usage
/// ```dart
/// IconButton3D(
///   icon: Icons.favorite,
///   color: Colors.pink,
///   rotationAxis: Axis3DRotation.y,
///   onPressed: () => toggleLike(),
/// )
/// ```
class IconButton3D extends StatefulWidget {
  final IconData icon;
  final Color color;
  final Color iconColor;
  final double size;
  final double depth;

  /// How many full rotations to perform per tap.
  final int rotations;

  /// Which axis the spin animation uses.
  final Axis3DRotation rotationAxis;

  /// Duration of one complete spin.
  final Duration spinDuration;

  final VoidCallback? onPressed;

  const IconButton3D({
    super.key,
    required this.icon,
    this.color         = const Color(0xFF42A5F5),
    this.iconColor     = Colors.white,
    this.size          = 52.0,
    this.depth         = 5.0,
    this.rotations     = 1,
    this.rotationAxis  = Axis3DRotation.y,
    this.spinDuration  = const Duration(milliseconds: 500),
    this.onPressed,
  });

  @override
  State<IconButton3D> createState() => _IconButton3DState();
}

class _IconButton3DState extends State<IconButton3D>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: widget.spinDuration,
  );

  late final Animation<double> _spin = Tween<double>(
    begin: 0,
    end: widget.rotations.toDouble(),
  ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

  // Press depth animation
  double _pressDepth = 0;

  void _onTap() {
    if (widget.onPressed == null || _ctrl.isAnimating) return;
    _ctrl.forward(from: 0).then((_) => widget.onPressed?.call());
  }

  void _onDown(TapDownDetails _) {
    if (widget.onPressed == null) return;
    setState(() => _pressDepth = widget.depth);
  }

  void _onUpOrCancel() {
    setState(() => _pressDepth = 0);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sideColor  = _darkenColor(widget.color, 0.22);
    final disabled   = widget.onPressed == null;
    final half       = widget.size / 2;

    return GestureDetector(
      onTap:       disabled ? null : _onTap,
      onTapDown:   disabled ? null : _onDown,
      onTapUp:     disabled ? null : (_) => _onUpOrCancel(),
      onTapCancel: disabled ? null : _onUpOrCancel,
      child: AnimatedBuilder(
        animation: _spin,
        builder: (ctx, child) {
          final angle = _spin.value * 2 * math.pi;

          Matrix4 spinMatrix;
          switch (widget.rotationAxis) {
            case Axis3DRotation.y:
              spinMatrix = Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(angle);
            case Axis3DRotation.x:
              spinMatrix = Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(angle);
            case Axis3DRotation.z:
              spinMatrix = Matrix4.identity()
                ..rotateZ(angle);
          }

          final currentDepth = widget.depth - _pressDepth;

          return Transform(
            alignment: Alignment.center,
            transform: spinMatrix,
            child: SizedBox(
              width:  widget.size,
              height: widget.size + currentDepth,
              child: CustomPaint(
                painter: _IconButton3DPainter(
                  faceColor: disabled ? Colors.grey.shade400 : widget.color,
                  sideColor: disabled ? Colors.grey.shade600 : sideColor,
                  depth:     currentDepth,
                  radius:    half,
                ),
                child: Center(
                  child: Icon(
                    widget.icon,
                    color: disabled ? Colors.white54 : widget.iconColor,
                    size:  widget.size * 0.46,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// The axis around which [IconButton3D] spins.
enum Axis3DRotation { x, y, z }

class _IconButton3DPainter extends CustomPainter {
  final Color faceColor;
  final Color sideColor;
  final double depth;
  final double radius;

  const _IconButton3DPainter({
    required this.faceColor,
    required this.sideColor,
    required this.depth,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final faceRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.width),
      Radius.circular(radius),
    );
    final sideRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, depth, size.width, size.width),
      Radius.circular(radius),
    );

    canvas.drawRRect(sideRect, Paint()..color = sideColor);
    canvas.drawRRect(faceRect, Paint()..color = faceColor);

    // Subtle top-left highlight
    canvas.drawRRect(
      faceRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white.withAlpha(50), Colors.transparent],
        ).createShader(
          Rect.fromLTWH(0, 0, size.width, size.width),
        ),
    );
  }

  @override
  bool shouldRepaint(_IconButton3DPainter old) =>
      old.depth     != depth     ||
      old.faceColor != faceColor;
}

Color _darkenColor(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
}
