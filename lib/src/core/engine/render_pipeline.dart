import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../foundation/three_d_scene.dart';

/// Manages the per-frame update cycle for [ThreeDScene]-based rendering.
///
/// [RenderPipeline] hooks into Flutter's [Ticker] (via [TickerProvider]) and
/// calls registered update callbacks every frame at the correct time in the
/// rendering pipeline.
///
/// Widgets that need per-frame simulation (physics springs, auto-rotation, etc.)
/// register themselves via [addCallback] and deregister via [removeCallback].
///
/// ### Lifecycle
/// 1. Create inside a [State] that mixes [TickerProviderStateMixin].
/// 2. Call [start] when the widget mounts.
/// 3. Call [stop] / [dispose] in [State.dispose].
class RenderPipeline {
  RenderPipeline({required TickerProvider vsync}) : _vsync = vsync;

  final TickerProvider _vsync;
  Ticker? _ticker;

  Duration _lastTimestamp = Duration.zero;
  Duration _elapsed       = Duration.zero;

  final List<FrameCallback> _callbacks = [];

  bool _running = false;

  // ─── Control ───────────────────────────────────────────────────────────────

  /// Starts the pipeline.  Safe to call multiple times.
  void start() {
    if (_running) return;
    _running = true;
    _ticker  = _vsync.createTicker(_onTick)..start();
  }

  /// Stops the pipeline without disposing it.
  void stop() {
    _running = false;
    _ticker?.stop();
  }

  /// Stops and releases the ticker.  Call from [State.dispose].
  void dispose() {
    stop();
    _ticker?.dispose();
    _ticker = null;
    _callbacks.clear();
  }

  // ─── Callback registration ─────────────────────────────────────────────────

  /// Registers [callback] to be called once per frame with [FrameInfo].
  void addCallback(FrameCallback callback) {
    if (!_callbacks.contains(callback)) _callbacks.add(callback);
  }

  /// Deregisters [callback].
  void removeCallback(FrameCallback callback) => _callbacks.remove(callback);

  // ─── Per-frame tick ────────────────────────────────────────────────────────

  void _onTick(Duration timestamp) {
    final dt = _lastTimestamp == Duration.zero
        ? Duration.zero
        : timestamp - _lastTimestamp;

    _lastTimestamp = timestamp;
    _elapsed      += dt;

    // Deliver to all registered callbacks
    for (final cb in List<FrameCallback>.from(_callbacks)) {
      cb(timestamp);
    }
  }

  // ─── Accessors ─────────────────────────────────────────────────────────────

  /// Total elapsed time since [start] was first called.
  Duration get elapsed => _elapsed;

  /// Whether the pipeline is currently running.
  bool get isRunning => _running;
}

/// A callback type received by [RenderPipeline.addCallback].
typedef FrameCallback = void Function(Duration timestamp);
