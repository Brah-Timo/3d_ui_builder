# Gesture System

`three_d_ui_builder` provides three gesture handlers that translate 2D user input into 3D-space interactions.

---

## Drag3DRecognizer

Converts a 2D pan drag into a 3D rotation quaternion delta.

**How it works:**

Horizontal drag → rotation around the Y-axis  
Vertical drag   → rotation around the X-axis  
The resulting `Quat` is the rotation that would have happened if the user dragged the surface of a virtual trackball.

```dart
Drag3DRecognizer({
  required Widget child,
  required void Function(Quat rotationDelta) onRotate,
  double sensitivity = 0.01,   // radians per logical pixel of drag
  bool   enabled     = true,
})
```

**Basic usage:**

```dart
class RotatableObject extends StatefulWidget {
  const RotatableObject({super.key});

  @override
  State<RotatableObject> createState() => _RotatableObjectState();
}

class _RotatableObjectState extends State<RotatableObject> {
  Quat _rotation = Quat.identity;

  @override
  Widget build(BuildContext context) {
    return Drag3DRecognizer(
      sensitivity: 0.008,
      onRotate: (delta) => setState(() => _rotation = _rotation * delta),
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..multiply(Matrix4Ext.trs(Vec3.zero, _rotation, Vec3.one)),
        child: const My3DWidget(),
      ),
    );
  }
}
```

**Sensitivity tuning:**

| Sensitivity | Feel |
|-------------|------|
| `0.005` | Slow, precise (good for detailed inspection) |
| `0.01` | Default — natural feeling |
| `0.02` | Fast, sweeping (good for action games) |

---

## PinchDepthRecognizer

Maps a two-finger pinch gesture to a Z-axis depth change (zoom in/out).

```dart
PinchDepthRecognizer({
  required Widget child,
  required void Function(double scale) onDepthChange,
  double minScale = 0.5,
  double maxScale = 3.0,
  bool   enabled  = true,
})
```

**Usage:**

```dart
class ZoomableScene extends StatefulWidget {
  const ZoomableScene({super.key});

  @override
  State<ZoomableScene> createState() => _ZoomableSceneState();
}

class _ZoomableSceneState extends State<ZoomableScene> {
  double _zoom = 1.0;

  @override
  Widget build(BuildContext context) {
    return PinchDepthRecognizer(
      onDepthChange: (scale) => setState(() => _zoom = scale),
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..scale(_zoom),
        child: const SceneContent(),
      ),
    );
  }
}
```

**Combined with Drag3DRecognizer:**

```dart
PinchDepthRecognizer(
  onDepthChange: (s) => setState(() => _zoom = s),
  child: Drag3DRecognizer(
    onRotate: (q) => setState(() => _rotation = _rotation * q),
    child: My3DScene(),
  ),
)
```

---

## GyroscopeTilt

Uses the device's physical gyroscope (via `sensors_plus`) to drive a tilt effect in real time.

On platforms without a gyroscope (Web, Desktop, simulators), the widget automatically falls back to a pointer-based hover tilt.

```dart
GyroscopeTilt({
  required Widget Function(BuildContext ctx, double tiltX, double tiltY) builder,
  double sensitivity   = 0.5,      // multiplier on raw gyro data
  double maxTiltRadians = 0.25,    // clamp to prevent extreme angles
  bool   invertX       = false,
  bool   invertY       = false,
  bool   enabled       = true,
})
```

**Example:**

```dart
GyroscopeTilt(
  sensitivity: 0.6,
  builder: (ctx, tiltX, tiltY) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateX(tiltX)
        ..rotateY(tiltY),
      child: const PremiumCard(),
    );
  },
)
```

**Coordinate mapping:**

| Gyroscope axis | Maps to | Effect |
|----------------|---------|--------|
| Pitch (rotation around X) | `tiltX` | Card tilts top/bottom |
| Roll (rotation around Y) | `tiltY` | Card tilts left/right |
| Yaw (rotation around Z) | ignored | (in-plane spin, not used) |

**Platform behaviour:**

| Platform | Gyroscope | Fallback |
|----------|-----------|----------|
| Android | ✅ Physical sensor | — |
| iOS | ✅ Physical sensor | — |
| Web | ❌ | `MouseRegion` hover-based tilt |
| macOS | ❌ | `MouseRegion` hover-based tilt |
| Windows | ❌ | `MouseRegion` hover-based tilt |
| Linux | ❌ | `MouseRegion` hover-based tilt |

---

## Combining Multiple Gestures

Flutter's `GestureArena` can conflict when combining multiple gesture recognisers.  The recommended composition order (outermost → innermost) is:

1. `PinchDepthRecognizer` — handles scale gestures (two-finger)
2. `Drag3DRecognizer` — handles pan gestures (one-finger)
3. Your `GestureDetector` — handles taps

```dart
PinchDepthRecognizer(
  onDepthChange: _onZoom,
  child: Drag3DRecognizer(
    onRotate: _onRotate,
    child: GestureDetector(
      onTap: _onTap,
      child: const MyWidget(),
    ),
  ),
)
```

---

## Manual Gesture Handling

If you need finer control, all gesture helpers expose their internal conversion functions as static utilities:

```dart
// Convert a 2D drag delta to a rotation quaternion
final Quat q = Drag3DRecognizer.deltaToQuat(
  dx: dragDetails.delta.dx,
  dy: dragDetails.delta.dy,
  sensitivity: 0.01,
);

// Convert gyroscope event to tilt angles (clamped)
final (double tiltX, double tiltY) = GyroscopeTilt.eventToTilt(
  event: gyroEvent,
  sensitivity: 0.5,
  maxRadians: 0.25,
);
```

---

## Inertia / Momentum

After a fast drag, you may want the rotation to coast to a stop.  Use a `FrictionSimulation` from `flutter/physics.dart`:

```dart
void _onDragEnd(DragEndDetails details) {
  final velocity = details.velocity.pixelsPerSecond;
  final sim = FrictionSimulation(
    0.135,         // friction coefficient (0.1 = slippery, 0.5 = sticky)
    _angularVelocity,
    velocity.dx * 0.01,
  );
  _inertiaCtr.animateWith(sim);
}
```
