import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A radial menu whose items are distributed evenly across the surface of a
/// virtual sphere using Fibonacci sphere packing.
///
/// Items are projected onto the screen using a simple perspective transform.
/// The sphere can be dragged to rotate, bringing different items to the front.
/// Items near the back of the sphere are smaller, dimmer, and drawn first.
///
/// ### Usage
/// ```dart
/// SphereMenu(
///   items: [
///     SphereMenuItem(icon: Icons.home,     label: 'Home',     onTap: () {}),
///     SphereMenuItem(icon: Icons.settings, label: 'Settings', onTap: () {}),
///     SphereMenuItem(icon: Icons.person,   label: 'Profile',  onTap: () {}),
///   ],
///   radius: 140,
///   autoRotate: true,
/// )
/// ```
class SphereMenu extends StatefulWidget {
  final List<SphereMenuItem> items;

  /// Sphere radius in logical pixels.
  final double radius;

  /// Size of each item widget.
  final double itemSize;

  /// Whether the sphere slowly rotates automatically.
  final bool autoRotate;

  /// Auto-rotation speed (radians per second).
  final double autoRotateSpeed;

  const SphereMenu({
    super.key,
    required this.items,
    this.radius          = 140,
    this.itemSize        = 52,
    this.autoRotate      = false,
    this.autoRotateSpeed = 0.4,
  });

  @override
  State<SphereMenu> createState() => _SphereMenuState();
}

class _SphereMenuState extends State<SphereMenu>
    with SingleTickerProviderStateMixin {
  // Euler rotation of the sphere
  double _rotX = -0.3;  // slight upward tilt by default
  double _rotY = 0.0;

  late final AnimationController _autoCtrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  )..addListener(_onAutoTick);

  double _dragStartX = 0;
  double _dragStartY = 0;
  double _dragRotX   = 0;
  double _dragRotY   = 0;
  bool   _dragging   = false;

  @override
  void initState() {
    super.initState();
    if (widget.autoRotate) _autoCtrl.repeat();
  }

  @override
  void dispose() {
    _autoCtrl.dispose();
    super.dispose();
  }

  void _onAutoTick() {
    if (!_dragging) {
      setState(() => _rotY += widget.autoRotateSpeed / 60);
    }
  }

  // ─── Drag ──────────────────────────────────────────────────────────────────

  void _onDragStart(DragStartDetails d) {
    _dragging      = true;
    _dragStartX    = d.localPosition.dx;
    _dragStartY    = d.localPosition.dy;
    _dragRotX      = _rotX;
    _dragRotY      = _rotY;
    _autoCtrl.stop();
  }

  void _onDragUpdate(DragUpdateDetails d) {
    final dx = d.localPosition.dx - _dragStartX;
    final dy = d.localPosition.dy - _dragStartY;
    setState(() {
      _rotY = _dragRotY + dx * 0.01;
      _rotX = (_dragRotX - dy * 0.01).clamp(-math.pi / 2, math.pi / 2);
    });
  }

  void _onDragEnd(DragEndDetails _) {
    _dragging = false;
    if (widget.autoRotate) _autoCtrl.repeat();
  }

  // ─── Sphere point generation ───────────────────────────────────────────────

  /// Generates evenly spaced points on the unit sphere using the
  /// Fibonacci lattice (sunflower spiral).
  List<_SpherePoint> _generatePoints() {
    final n      = widget.items.length;
    final golden = (1 + math.sqrt(5)) / 2;
    final points = <_SpherePoint>[];

    for (int i = 0; i < n; i++) {
      final theta = math.acos(1 - 2 * (i + 0.5) / n);   // polar angle
      final phi   = 2 * math.pi * i / golden;             // azimuthal angle

      // Cartesian on unit sphere
      double x = math.sin(theta) * math.cos(phi);
      double y = math.cos(theta);
      double z = math.sin(theta) * math.sin(phi);

      // Apply sphere rotation
      final rotated = _rotateXY(x, y, z);
      x = rotated.$1;
      y = rotated.$2;
      z = rotated.$3;

      points.add(_SpherePoint(x: x, y: y, z: z, itemIndex: i));
    }

    // Sort back-to-front
    points.sort((a, b) => a.z.compareTo(b.z));
    return points;
  }

  (double, double, double) _rotateXY(double x, double y, double z) {
    // Rotate around X
    final y1 = y * math.cos(_rotX) - z * math.sin(_rotX);
    final z1 = y * math.sin(_rotX) + z * math.cos(_rotX);

    // Rotate around Y
    final x2 = x * math.cos(_rotY) + z1 * math.sin(_rotY);
    final z2 = -x * math.sin(_rotY) + z1 * math.cos(_rotY);

    return (x2, y1, z2);
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final diameter = widget.radius * 2.4;
    final points   = _generatePoints();

    return GestureDetector(
      onPanStart:  _onDragStart,
      onPanUpdate: _onDragUpdate,
      onPanEnd:    _onDragEnd,
      child: SizedBox(
        width:  diameter,
        height: diameter,
        child: Stack(
          alignment: Alignment.center,
          children: points.map((pt) {
            final item = widget.items[pt.itemIndex];

            // Perspective projection
            final focalLength = widget.radius * 2.5;
            final scale2d     = focalLength / (focalLength + pt.z * widget.radius);
            final screenX     = pt.x * widget.radius * scale2d;
            final screenY     = pt.y * widget.radius * scale2d;

            final normZ       = (pt.z + 1) / 2;   // 0..1
            final opacity     = (0.3 + 0.7 * normZ).clamp(0.0, 1.0);
            final itemScale   = (0.55 + 0.45 * normZ) * scale2d;
            final itemSz      = widget.itemSize * itemScale;

            return Positioned(
              left:   diameter / 2 + screenX - itemSz / 2,
              top:    diameter / 2 + screenY - itemSz / 2,
              width:  itemSz,
              height: itemSz,
              child: Opacity(
                opacity: opacity,
                child: GestureDetector(
                  onTap: item.onTap,
                  child: _SphereItemWidget(
                    item:        item,
                    size:        itemSz,
                    isFront:     pt.z > 0.3,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ─── Item widget ──────────────────────────────────────────────────────────────

class _SphereItemWidget extends StatelessWidget {
  final SphereMenuItem item;
  final double         size;
  final bool           isFront;

  const _SphereItemWidget({
    required this.item,
    required this.size,
    required this.isFront,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = size * 0.42;
    return DecoratedBox(
      decoration: BoxDecoration(
        color:        item.color.withAlpha(isFront ? 230 : 160),
        shape:        BoxShape.circle,
        boxShadow: isFront
            ? [
                BoxShadow(
                  color:      Colors.black.withAlpha(50),
                  blurRadius: 8,
                  offset:     const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Icon(item.icon, color: Colors.white, size: iconSize),
      ),
    );
  }
}

// ─── Supporting types ─────────────────────────────────────────────────────────

/// A single item in a [SphereMenu].
class SphereMenuItem {
  final IconData  icon;
  final String    label;
  final Color     color;
  final VoidCallback? onTap;

  const SphereMenuItem({
    required this.icon,
    required this.label,
    this.color = const Color(0xFF5C6BC0),
    this.onTap,
  });
}

class _SpherePoint {
  final double x, y, z;
  final int    itemIndex;
  const _SpherePoint({
    required this.x,
    required this.y,
    required this.z,
    required this.itemIndex,
  });
}
