import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../core/math/quaternion.dart';
import '../../core/math/vector3.dart';

/// Manages the view-space camera used by [ThreeDSceneWidget].
///
/// The camera is described by:
/// - [position] — where the camera is in world space.
/// - [target]   — the point the camera is looking at.
/// - [up]       — the up direction (usually [Vec3.up]).
///
/// All mutations call [notifyListeners], which triggers a [ThreeDSceneWidget]
/// rebuild.
///
/// ### Usage
/// ```dart
/// final camera = CameraController(
///   position: const Vec3(0, -50, 300),
///   target:   Vec3.zero,
/// );
///
/// // Orbit-drag:
/// camera.orbit(deltaX: 0.02, deltaY: -0.01);
///
/// // Zoom in:
/// camera.zoom(delta: -20);
/// ```
class CameraController extends ChangeNotifier {
  Vec3 _position;
  Vec3 _target;
  Vec3 _up;

  /// Minimum allowed distance from [target] (zoom-in limit).
  final double minDistance;

  /// Maximum allowed distance from [target] (zoom-out limit).
  final double maxDistance;

  CameraController({
    Vec3   position    = const Vec3(0, -80, 400),
    Vec3   target      = Vec3.zero,
    Vec3   up          = Vec3.up,
    this.minDistance   = 50,
    this.maxDistance   = 2000,
  })  : _position = position,
        _target   = target,
        _up       = up;

  // ─── Accessors ────────────────────────────────────────────────────────────

  Vec3 get position  => _position;
  Vec3 get target    => _target;
  Vec3 get up        => _up;

  /// Distance from camera to target.
  double get distance => (_position - _target).length;

  // ─── Mutation API ─────────────────────────────────────────────────────────

  void setPosition(Vec3 position) {
    _position = position;
    notifyListeners();
  }

  void setTarget(Vec3 target) {
    _target = target;
    notifyListeners();
  }

  /// Orbits the camera around [target] by [deltaX] (azimuth) and
  /// [deltaY] (elevation) angles in radians.
  void orbit({required double deltaX, required double deltaY}) {
    final offset    = _position - _target;
    final horizontal = Quat.axisAngle(Vec3.up, -deltaX);
    final right      = offset.cross(Vec3.up).normalized;
    final vertical   = Quat.axisAngle(right, -deltaY);
    final rotated    = (horizontal * vertical).rotate(offset);
    _position        = _target + rotated;
    notifyListeners();
  }

  /// Moves the camera closer to or further from [target].
  /// Positive [delta] = zoom in; negative = zoom out.
  void zoom({required double delta}) {
    final dir  = (_target - _position).normalized;
    final newPos = _position + dir * delta;
    final newDist = (newPos - _target).length;
    if (newDist < minDistance || newDist > maxDistance) return;
    _position = newPos;
    notifyListeners();
  }

  /// Pans the camera and target by [delta] in view space.
  void pan(Offset delta) {
    final right   = (_target - _position).cross(_up).normalized;
    final trueUp  = right.cross((_target - _position).normalized);
    final move    = right * delta.dx + trueUp * (-delta.dy);
    _position    += move;
    _target      += move;
    notifyListeners();
  }

  // ─── View matrix ──────────────────────────────────────────────────────────

  /// Returns the view matrix for this camera.
  Matrix4 get viewMatrix {
    final f = (_target - _position).normalized;
    final s = f.cross(_up).normalized;
    final u = s.cross(f);

    return Matrix4.fromList([
      s.x,   u.x,  -f.x,   0,
      s.y,   u.y,  -f.y,   0,
      s.z,   u.z,  -f.z,   0,
      -s.dot(_position), -u.dot(_position), f.dot(_position), 1,
    ]);
  }
}
