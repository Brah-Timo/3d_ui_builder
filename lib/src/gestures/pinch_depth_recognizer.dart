import 'package:flutter/widgets.dart';

/// Converts a two-finger pinch gesture into a Z-depth (zoom) delta.
///
/// Pinching in  (fingers approaching) decreases depth — moves the object away.
/// Pinching out (fingers spreading)   increases depth — brings the object closer.
///
/// ### Usage
/// ```dart
/// final pinch = PinchDepthRecognizer(
///   onDepthChanged: (delta) {
///     setState(() => _z += delta);
///   },
/// );
///
/// GestureDetector(
///   onScaleStart:  pinch.onScaleStart,
///   onScaleUpdate: pinch.onScaleUpdate,
///   onScaleEnd:    pinch.onScaleEnd,
///   child: MyWidget(),
/// )
/// ```
class PinchDepthRecognizer {
  /// Called with the Z-depth delta each scale update.
  final void Function(double depthDelta) onDepthChanged;

  /// Multiplier: how many logical pixels to move per unit of scale change.
  final double depthPerUnit;

  /// Minimum scale ratio — rejects micro-changes to avoid jitter.
  final double threshold;

  PinchDepthRecognizer({
    required this.onDepthChanged,
    this.depthPerUnit = 200,
    this.threshold    = 0.005,
  });

  double _lastScale = 1.0;

  // ─── Handlers ─────────────────────────────────────────────────────────────

  void onScaleStart(ScaleStartDetails _) {
    _lastScale = 1.0;
  }

  void onScaleUpdate(ScaleUpdateDetails d) {
    final delta = d.scale - _lastScale;
    if (delta.abs() < threshold) return;
    _lastScale = d.scale;
    onDepthChanged(delta * depthPerUnit);
  }

  void onScaleEnd(ScaleEndDetails _) {
    _lastScale = 1.0;
  }
}
