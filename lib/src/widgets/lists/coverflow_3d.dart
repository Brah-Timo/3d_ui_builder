import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The classic iTunes CoverFlow effect: a horizontal list where adjacent cards
/// are rotated around the Y-axis, giving depth to the selected item.
///
/// The centred item is displayed flat and full-size.  Items to the left are
/// rotated +[sideAngle] degrees and items to the right are rotated -[sideAngle]
/// degrees, with perspective applied so they appear to recede behind the
/// selected item.
///
/// Swiping left or right animates to the previous or next item with a smooth
/// physics-based spring.
///
/// ### Usage
/// ```dart
/// CoverFlow3D(
///   itemCount: albums.length,
///   itemBuilder: (ctx, i) => AlbumArt(albums[i]),
///   itemWidth:   220,
///   itemHeight:  220,
///   sideAngle:   55,
/// )
/// ```
class CoverFlow3D extends StatefulWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  /// Width of each item in logical pixels.
  final double itemWidth;

  /// Height of each item in logical pixels.
  final double itemHeight;

  /// Rotation angle of non-centred items in degrees.
  final double sideAngle;

  /// Horizontal gap between items (centre-to-centre distance).
  final double spacing;

  /// Perspective coefficient.
  final double perspective;

  /// Initial item index (0-based).
  final int initialIndex;

  /// Called when the selected index changes.
  final ValueChanged<int>? onIndexChanged;

  const CoverFlow3D({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.itemWidth    = 200,
    this.itemHeight   = 200,
    this.sideAngle    = 55,
    this.spacing      = 120,
    this.perspective  = 0.001,
    this.initialIndex = 0,
    this.onIndexChanged,
  });

  @override
  State<CoverFlow3D> createState() => _CoverFlow3DState();
}

class _CoverFlow3DState extends State<CoverFlow3D>
    with SingleTickerProviderStateMixin {
  late double _offset;  // fractional item offset (0.0 = item 0 centred, 1.0 = item 1)

  late final AnimationController _springCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );

  Animation<double>? _snapAnim;

  double _dragStartX = 0;
  double _dragStartOffset = 0;

  @override
  void initState() {
    super.initState();
    _offset = widget.initialIndex.toDouble();
  }

  int get _selectedIndex =>
      _offset.round().clamp(0, widget.itemCount - 1);

  // ─── Drag ──────────────────────────────────────────────────────────────────

  void _onDragStart(DragStartDetails d) {
    _springCtrl.stop();
    _dragStartX      = d.localPosition.dx;
    _dragStartOffset = _offset;
  }

  void _onDragUpdate(DragUpdateDetails d) {
    final delta = (d.localPosition.dx - _dragStartX) / widget.spacing;
    setState(() => _offset = (_dragStartOffset - delta)
        .clamp(0, widget.itemCount - 1.0));
  }

  void _onDragEnd(DragEndDetails d) {
    // Velocity-based snap: if fast swipe, go to next/prev
    final velocity = d.velocity.pixelsPerSecond.dx;
    int target     = _offset.round();
    if (velocity >  400 && target > 0) target--;
    if (velocity < -400 && target < widget.itemCount - 1) target++;

    _snapTo(target.toDouble());
  }

  void _snapTo(double target) {
    final from = _offset;
    _snapAnim  = Tween<double>(begin: from, end: target).animate(
      CurvedAnimation(parent: _springCtrl, curve: Curves.elasticOut),
    )..addListener(() {
        if (mounted) setState(() => _offset = _snapAnim!.value);
      })
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) {
          widget.onIndexChanged?.call(_selectedIndex);
        }
      });
    _springCtrl.forward(from: 0);
  }

  // ─── Item matrix ───────────────────────────────────────────────────────────

  Matrix4 _matrixForItem(int index) {
    final diff = index - _offset;  // negative = left, positive = right

    final absD    = diff.abs().clamp(0.0, 2.5);
    final sign    = diff.sign;
    final angleRad = sign * math.min(absD, 1) * widget.sideAngle * math.pi / 180;

    // Items further away are pushed back in Z
    final double zShift = -absD.clamp(0.0, 2.0) * 60.0;

    return Matrix4.identity()
      ..setEntry(3, 2, widget.perspective)
      ..translate(0.0, 0.0, zShift)
      ..rotateY(angleRad);
  }

  double _xOffsetForItem(int index) {
    final diff  = index - _offset;
    final absD  = diff.abs();
    final sign  = diff.sign;

    if (absD < 1) {
      return sign * absD * widget.spacing;
    }
    // Once past 1 item away, tighten spacing so covers stack up
    return sign * (widget.spacing + (absD - 1) * widget.spacing * 0.5);
  }

  double _opacityForItem(int index) {
    final diff = (index - _offset).abs();
    if (diff > 2.5) return 0;
    return (1 - diff / 2.8).clamp(0.3, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.itemCount == 0) return const SizedBox.shrink();

    final containerWidth = widget.itemWidth * 3;

    return GestureDetector(
      onHorizontalDragStart:  _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd:    _onDragEnd,
      child: SizedBox(
        width:  containerWidth,
        height: widget.itemHeight + 20,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          // Sorted: items further away drawn first
          children: _buildItems(),
        ),
      ),
    );
  }

  List<Widget> _buildItems() {
    final visible = <_CoverEntry>[];

    for (int i = 0; i < widget.itemCount; i++) {
      final diff = (i - _offset).abs();
      if (diff > 3) continue;  // cull far items
      visible.add(_CoverEntry(
        index: i,
        depth: -(diff * 60).toDouble(),
        xOffset: _xOffsetForItem(i),
        matrix: _matrixForItem(i),
        opacity: _opacityForItem(i),
      ));
    }

    // Back-to-front
    visible.sort((a, b) => a.depth.compareTo(b.depth));

    return visible.map((e) => Positioned(
      left: (containerWidth / 2 - widget.itemWidth / 2) + e.xOffset,
      top:  10,
      width:  widget.itemWidth,
      height: widget.itemHeight,
      child: Opacity(
        opacity: e.opacity,
        child: Transform(
          alignment: Alignment.center,
          transform: e.matrix,
          child: widget.itemBuilder(context, e.index),
        ),
      ),
    )).toList();
  }

  double get containerWidth => widget.itemWidth * 3;
}

class _CoverEntry {
  final int    index;
  final double depth;
  final double xOffset;
  final Matrix4 matrix;
  final double opacity;
  const _CoverEntry({
    required this.index,
    required this.depth,
    required this.xOffset,
    required this.matrix,
    required this.opacity,
  });
}
