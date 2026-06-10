import 'dart:math' as math;

import 'package:flutter/material.dart';

/// An interactive 3-D cube where each of the six faces is an independent
/// widget.  The cube can be freely rotated by dragging, or programmatically
/// navigated to show a specific face.
///
/// The cube uses Flutter's [Transform] widget stack with computed [Matrix4]
/// transforms for each face — no GPU scene graph required.
///
/// ### Usage
/// ```dart
/// CubeContainer(
///   size: 260,
///   front:  HomeScreen(),
///   back:   SettingsScreen(),
///   left:   ProfileScreen(),
///   right:  NotificationsScreen(),
///   top:    SearchScreen(),
///   bottom: HelpScreen(),
///   onFaceVisible: (face) => print('Showing $face'),
/// )
/// ```
class CubeContainer extends StatefulWidget {
  final double size;

  final Widget front;
  final Widget back;
  final Widget left;
  final Widget right;
  final Widget top;
  final Widget bottom;

  /// Called when a face is brought to the front via [CubeController].
  final ValueChanged<CubeFace>? onFaceVisible;

  /// Programmatic control.
  final CubeController? controller;

  /// Perspective coefficient — higher = more dramatic.
  final double perspective;

  /// Drag sensitivity multiplier.
  final double dragSensitivity;

  const CubeContainer({
    super.key,
    required this.size,
    required this.front,
    required this.back,
    required this.left,
    required this.right,
    required this.top,
    required this.bottom,
    this.onFaceVisible,
    this.controller,
    this.perspective     = 0.001,
    this.dragSensitivity = 0.01,
  });

  @override
  State<CubeContainer> createState() => CubeContainerState();
}

class CubeContainerState extends State<CubeContainer>
    with SingleTickerProviderStateMixin {
  double _rotX = -0.2;  // radians (slight downward tilt)
  double _rotY =  0.3;  // radians (slight right tilt)

  late final AnimationController _snapCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 550),
  );

  Animation<double>? _snapX;
  Animation<double>? _snapY;

  @override
  void initState() {
    super.initState();
    widget.controller?._bind(this);
  }

  @override
  void dispose() {
    _snapCtrl.dispose();
    super.dispose();
  }

  // ─── Public API ────────────────────────────────────────────────────────────

  void showFace(CubeFace face) {
    double targetX = 0;
    double targetY = 0;

    switch (face) {
      case CubeFace.front:  targetX = 0;              targetY = 0;
      case CubeFace.back:   targetX = 0;              targetY = math.pi;
      case CubeFace.left:   targetX = 0;              targetY = -math.pi / 2;
      case CubeFace.right:  targetX = 0;              targetY =  math.pi / 2;
      case CubeFace.top:    targetX = -math.pi / 2;  targetY = 0;
      case CubeFace.bottom: targetX =  math.pi / 2;  targetY = 0;
    }

    final fromX = _rotX;
    final fromY = _rotY;

    _snapX = Tween<double>(begin: fromX, end: targetX).animate(
      CurvedAnimation(parent: _snapCtrl, curve: Curves.easeInOut),
    )..addListener(() {
        if (mounted) setState(() => _rotX = _snapX!.value);
      });

    _snapY = Tween<double>(begin: fromY, end: targetY).animate(
      CurvedAnimation(parent: _snapCtrl, curve: Curves.easeInOut),
    )..addListener(() {
        if (mounted) setState(() => _rotY = _snapY!.value);
      })
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) {
          widget.onFaceVisible?.call(face);
        }
      });

    _snapCtrl.forward(from: 0);
  }

  // ─── Drag ──────────────────────────────────────────────────────────────────

  void _onDragUpdate(DragUpdateDetails d) {
    _snapCtrl.stop();
    setState(() {
      _rotY += d.delta.dx * widget.dragSensitivity;
      _rotX -= d.delta.dy * widget.dragSensitivity;
    });
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final half = widget.size / 2;

    final cubeTransform = Matrix4.identity()
      ..setEntry(3, 2, widget.perspective)
      ..rotateX(_rotX)
      ..rotateY(_rotY);

    return GestureDetector(
      onPanUpdate: _onDragUpdate,
      child: SizedBox(
        width:  widget.size,
        height: widget.size,
        child: Transform(
          alignment: Alignment.center,
          transform: cubeTransform,
          child: SizedBox(
            width:  widget.size,
            height: widget.size,
            child: Stack(
              children: [
                _face(widget.front,  _frontMatrix(half)),
                _face(widget.back,   _backMatrix(half)),
                _face(widget.left,   _leftMatrix(half)),
                _face(widget.right,  _rightMatrix(half)),
                _face(widget.top,    _topMatrix(half)),
                _face(widget.bottom, _bottomMatrix(half)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _face(Widget child, Matrix4 transform) {
    return Transform(
      transform: transform,
      child: SizedBox.square(
        dimension: widget.size,
        child: ClipRect(child: child),
      ),
    );
  }

  // ─── Face matrices ─────────────────────────────────────────────────────────

  static Matrix4 _frontMatrix(double half) => Matrix4.identity()
    ..translate(0.0, 0.0, half);

  static Matrix4 _backMatrix(double half) => Matrix4.identity()
    ..translate(0.0, 0.0, -half)
    ..rotateY(math.pi);

  static Matrix4 _leftMatrix(double half) => Matrix4.identity()
    ..translate(-half, 0.0, 0.0)
    ..rotateY(-math.pi / 2);

  static Matrix4 _rightMatrix(double half) => Matrix4.identity()
    ..translate(half, 0.0, 0.0)
    ..rotateY(math.pi / 2);

  static Matrix4 _topMatrix(double half) => Matrix4.identity()
    ..translate(0.0, -half, 0.0)
    ..rotateX(math.pi / 2);

  static Matrix4 _bottomMatrix(double half) => Matrix4.identity()
    ..translate(0.0, half, 0.0)
    ..rotateX(-math.pi / 2);
}

// ─── Controller & Enum ───────────────────────────────────────────────────────

/// Programmatic control handle for [CubeContainer].
class CubeController {
  CubeContainerState? _state;
  void _bind(CubeContainerState s) => _state = s;

  /// Animates the cube to show [face].
  void showFace(CubeFace face) => _state?.showFace(face);
}

/// Identifies one of the six faces of a [CubeContainer].
enum CubeFace { front, back, left, right, top, bottom }
