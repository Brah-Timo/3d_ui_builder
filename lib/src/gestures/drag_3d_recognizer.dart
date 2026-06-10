import 'package:flutter/widgets.dart';

import '../core/math/quaternion.dart';
import '../core/math/vector3.dart';

/// Converts a 2-D pointer drag into a 3-D arcball rotation.
///
/// The "arcball" model maps pointer movement on a flat screen to rotation
/// vectors on an imaginary sphere that encloses the widget.  Dragging in X
/// rotates around the global Y-axis; dragging in Y rotates around the global
/// X-axis.  Diagonal drags produce combined rotations with no Gimbal Lock.
///
/// ### Usage
/// ```dart
/// final recognizer = Drag3DRecognizer(
///   onRotationUpdate: (delta) {
///     setState(() {
///       _currentRotation = delta * _currentRotation;
///     });
///   },
/// );
///
/// GestureDetector(
///   onPanStart:  recognizer.onPanStart,
///   onPanUpdate: recognizer.onPanUpdate,
///   onPanEnd:    recognizer.onPanEnd,
///   child: MyWidget(),
/// )
/// ```
class Drag3DRecognizer {
  /// Called with the incremental rotation quaternion each frame.
  final void Function(Quat deltaRotation) onRotationUpdate;

  /// Called when the drag begins.
  final VoidCallback? onDragStart;

  /// Called when the drag ends (with final velocity in logical pixels/sec).
  final void Function(Offset velocity)? onDragEnd;

  /// Sensitivity multiplier.  Higher = more rotation per pixel.
  final double sensitivity;

  Drag3DRecognizer({
    required this.onRotationUpdate,
    this.onDragStart,
    this.onDragEnd,
    this.sensitivity = 0.5,
  });

  Offset? _lastPosition;

  // ─── Handlers ─────────────────────────────────────────────────────────────

  void onPanStart(DragStartDetails d) {
    _lastPosition = d.localPosition;
    onDragStart?.call();
  }

  void onPanUpdate(DragUpdateDetails d) {
    final last = _lastPosition;
    if (last == null) return;

    final dx = d.localPosition.dx - last.dx;
    final dy = d.localPosition.dy - last.dy;
    _lastPosition = d.localPosition;

    if (dx.abs() < 0.1 && dy.abs() < 0.1) return;

    // Convert 2-D delta to 3-D rotation:
    // - dx → rotate around Y-axis
    // - dy → rotate around X-axis
    final angleY = dx * sensitivity * 3.14159 / 180;
    final angleX = dy * sensitivity * 3.14159 / 180;

    final qX = Quat.axisAngle(Vec3.right, angleX);
    final qY = Quat.axisAngle(Vec3.up,    angleY);

    onRotationUpdate(qY * qX);
  }

  void onPanEnd(DragEndDetails d) {
    _lastPosition = null;
    onDragEnd?.call(d.velocity.pixelsPerSecond);
  }

  void onPanCancel() {
    _lastPosition = null;
    onDragEnd?.call(Offset.zero);
  }
}
