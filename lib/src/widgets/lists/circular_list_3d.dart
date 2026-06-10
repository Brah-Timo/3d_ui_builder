import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A carousel that arranges its items on a circular ring in 3-D space.
///
/// Items are distributed evenly around the ring.  As the list rotates,
/// perspective scaling and opacity make items closer to the viewer appear
/// larger and more opaque than items in the back.
///
/// Rotation can be driven by horizontal drag or by enabling [autoRotate].
///
/// ### Usage
/// ```dart
/// CircularList3D(
///   itemCount: 8,
///   itemBuilder: (ctx, index) => MyCard(items[index]),
///   radius: 200,
///   tiltAngle: 0.4,
///   autoRotate: true,
///   rotationSpeed: 0.25,
/// )
/// ```
class CircularList3D extends StatefulWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  /// Ring radius in logical pixels.
  final double radius;

  /// Tilt of the ring toward the viewer (radians).
  /// `0` = ring lies flat (all items at same Y); `pi/2` = ring stands vertical.
  final double tiltAngle;

  /// Perspective coefficient applied to each item's Transform.
  final double perspective;

  /// Whether the ring spins automatically.
  final bool autoRotate;

  /// Auto-rotation speed in full rotations per second.
  final double rotationSpeed;

  /// Direction of auto-rotation.
  final RotationDirection rotationDirection;

  /// Whether to snap to the nearest item after a drag ends.
  final bool snapOnRelease;

  const CircularList3D({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.radius           = 180,
    this.tiltAngle        = 0.3,
    this.perspective      = 0.001,
    this.autoRotate       = false,
    this.rotationSpeed    = 0.25,
    this.rotationDirection = RotationDirection.clockwise,
    this.snapOnRelease    = false,
  });

  @override
  State<CircularList3D> createState() => _CircularList3DState();
}

class _CircularList3DState extends State<CircularList3D>
    with SingleTickerProviderStateMixin {
  late final AnimationController _autoCtrl = AnimationController(
    vsync: this,
    duration: Duration(
      microseconds: (1000000 / widget.rotationSpeed.clamp(0.01, 100)).round(),
    ),
  );

  double _baseAngle    = 0;   // cumulative angle from drags
  double _autoAngle    = 0;   // angle contributed by auto-rotate
  double _dragStart    = 0;
  double _dragAngleStart = 0;
  bool   _isDragging   = false;

  @override
  void initState() {
    super.initState();
    _autoCtrl.addListener(_onAutoTick);
    if (widget.autoRotate) _autoCtrl.repeat();
  }

  @override
  void dispose() {
    _autoCtrl.dispose();
    super.dispose();
  }

  void _onAutoTick() {
    if (!_isDragging) {
      setState(() {
        final direction = widget.rotationDirection == RotationDirection.clockwise
            ? 1.0
            : -1.0;
        _autoAngle = _autoCtrl.value * 2 * math.pi * direction;
      });
    }
  }

  double get _totalAngle => _baseAngle + _autoAngle;

  // ─── Drag ──────────────────────────────────────────────────────────────────

  void _onDragStart(DragStartDetails d) {
    _isDragging      = true;
    _dragStart       = d.localPosition.dx;
    _dragAngleStart  = _baseAngle;
    _autoCtrl.stop();
  }

  void _onDragUpdate(DragUpdateDetails d) {
    final delta = d.localPosition.dx - _dragStart;
    setState(() => _baseAngle = _dragAngleStart + delta * 0.008);
  }

  void _onDragEnd(DragEndDetails _) {
    _isDragging = false;
    if (widget.snapOnRelease) _snapToNearest();
    if (widget.autoRotate) _autoCtrl.repeat();
  }

  void _snapToNearest() {
    if (widget.itemCount == 0) return;
    final step     = (2 * math.pi) / widget.itemCount;
    final rounded  = (_baseAngle / step).round() * step;
    setState(() => _baseAngle = rounded);
  }

  // ─── Item position ─────────────────────────────────────────────────────────

  _ItemData _itemData(int index) {
    final step  = (2 * math.pi) / widget.itemCount;
    final angle = step * index + _totalAngle;

    final x = widget.radius * math.sin(angle);
    final y = widget.radius * math.sin(widget.tiltAngle) * math.cos(angle);
    final z = widget.radius * math.cos(angle);

    final normZ  = (z / widget.radius + 1) / 2;  // 0..1
    final scale  = 0.55 + 0.45 * normZ;
    final opacity = 0.4 + 0.6 * normZ;

    return _ItemData(x: x, y: y, z: z, scale: scale, opacity: opacity);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.itemCount == 0) return const SizedBox.shrink();

    // Collect all items with their z-depth for sorting
    final entries = List.generate(widget.itemCount, (i) {
      final d = _itemData(i);
      return _PositionedItem(index: i, data: d);
    })..sort((a, b) => a.data.z.compareTo(b.data.z)); // back-to-front

    final diameter = widget.radius * 2.6;

    return GestureDetector(
      onHorizontalDragStart:  _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd:    _onDragEnd,
      child: SizedBox(
        width:  diameter,
        height: diameter * 0.65,
        child: Stack(
          alignment: Alignment.center,
          children: entries.map((e) {
            final d    = e.data;
            final size = 100.0 * d.scale;

            return Positioned(
              left:   diameter / 2 + d.x - size / 2,
              top:    diameter * 0.32 + d.y - size / 2,
              width:  size,
              height: size,
              child: Opacity(
                opacity: d.opacity.clamp(0.0, 1.0),
                child: widget.itemBuilder(context, e.index),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _ItemData {
  final double x, y, z, scale, opacity;
  const _ItemData({
    required this.x,
    required this.y,
    required this.z,
    required this.scale,
    required this.opacity,
  });
}

class _PositionedItem {
  final int index;
  final _ItemData data;
  const _PositionedItem({required this.index, required this.data});
}

/// Auto-rotation direction for [CircularList3D].
enum RotationDirection { clockwise, counterClockwise }
