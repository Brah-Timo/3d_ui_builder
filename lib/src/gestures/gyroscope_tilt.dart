import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Listens to the device gyroscope and exposes a smoothed tilt offset as a
/// [ValueNotifier<Offset>].
///
/// [GyroscopeTilt] integrates the gyroscope angular velocity over time and
/// applies a low-pass filter to reduce jitter.  The resulting [tilt] value
/// can be used to tilt widgets, pan cameras, or create parallax effects.
///
/// ### Usage
/// ```dart
/// final gyro = GyroscopeTilt(sensitivity: 10);
/// gyro.start();
///
/// ValueListenableBuilder<Offset>(
///   valueListenable: gyro.tilt,
///   builder: (ctx, tilt, child) {
///     return Transform(
///       transform: Matrix4.identity()
///         ..setEntry(3, 2, 0.001)
///         ..rotateX(tilt.dy)
///         ..rotateY(-tilt.dx),
///       alignment: Alignment.center,
///       child: child,
///     );
///   },
///   child: MyWidget(),
/// )
///
/// // Don't forget to stop when done:
/// gyro.stop();
/// gyro.dispose();
/// ```
class GyroscopeTilt {
  /// The current tilt as a 2-D offset.
  ///
  /// [Offset.dx] = rotation around Y-axis (yaw).
  /// [Offset.dy] = rotation around X-axis (pitch).
  final ValueNotifier<Offset> tilt = ValueNotifier(Offset.zero);

  /// How aggressively the gyro reading is scaled.
  final double sensitivity;

  /// Low-pass filter coefficient [0, 1].
  /// Closer to 1 = more smoothing; closer to 0 = more responsive.
  final double smoothing;

  /// Clamp each axis to ± [maxTiltRadians].
  final double maxTiltRadians;

  StreamSubscription<GyroscopeEvent>? _sub;

  GyroscopeTilt({
    this.sensitivity    = 8.0,
    this.smoothing      = 0.85,
    this.maxTiltRadians = 0.5,
  });

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  /// Begins listening to gyroscope events.
  void start() {
    _sub ??= gyroscopeEventStream().listen(_onEvent);
  }

  /// Stops listening.  The [tilt] value is preserved until [reset] is called.
  void stop() {
    _sub?.cancel();
    _sub = null;
  }

  /// Resets [tilt] to [Offset.zero].
  void reset() {
    tilt.value = Offset.zero;
  }

  /// Stops listening and disposes the notifier.
  void dispose() {
    stop();
    tilt.dispose();
  }

  // ─── Internal ─────────────────────────────────────────────────────────────

  void _onEvent(GyroscopeEvent event) {
    final current = tilt.value;

    // Integrate angular velocity (multiply by a fixed Δt ≈ 1/60 s)
    final rawX = current.dx + event.y * sensitivity * 0.016;
    final rawY = current.dy + event.x * sensitivity * 0.016;

    // Low-pass filter
    final smoothX = rawX * (1 - smoothing) + current.dx * smoothing;
    final smoothY = rawY * (1 - smoothing) + current.dy * smoothing;

    tilt.value = Offset(
      smoothX.clamp(-maxTiltRadians, maxTiltRadians),
      smoothY.clamp(-maxTiltRadians, maxTiltRadians),
    );
  }
}
