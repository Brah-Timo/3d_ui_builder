# Animation System

`three_d_ui_builder` plugs directly into Flutter's existing `AnimationController` infrastructure. All animation classes are standard `Animation<T>` objects — you can compose them with `CurvedAnimation`, listen to them with `AnimatedBuilder`, or chain them with `TweenSequence`.

---

## Transform3DTween

The most general animation primitive: tweens between any two `Transform3D` values.

```dart
late final AnimationController _ctrl = AnimationController(
  vsync: this,
  duration: const Duration(milliseconds: 800),
);

late final Animation<Transform3D> _anim = Transform3DTween(
  begin: Transform3D.identity,
  end: Transform3D(
    position: const Vec3(0, -60, 0),
    rotation: Quat.axisAngle(Vec3.up, math.pi / 2),
    scale:    Vec3.one,
  ),
).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

// In build:
AnimatedBuilder(
  animation: _anim,
  builder: (ctx, child) => Transform(
    alignment: Alignment.center,
    transform: _anim.value.toMatrix4Perspective(),
    child: child,
  ),
  child: const MyWidget(),
)
```

**Interpolation details:**
- Position: linear lerp
- Rotation: SLERP (quaternion spherical linear interpolation) — constant angular speed, shortest arc
- Scale: linear lerp per component

---

## RotationAnimation

An `Animation<Quat>` that interpolates between two orientations using SLERP.

```dart
final anim = RotationAnimation(
  controller: _ctrl,
  from: Quat.identity,
  to:   Quat.axisAngle(Vec3.up, math.pi),
  curve: Curves.easeInOut,
);

// Use the Quat value to build a rotation matrix
final q = anim.value;
final m = Matrix4.identity()
  ..setEntry(3, 2, 0.001)
  ..multiply(q.toMatrix4());  // via Matrix4Ext
```

**Why SLERP instead of lerp?**

Plain quaternion lerp + normalise produces an animation that speeds up in the middle (because the linear path through 4D space is shorter there). SLERP traces the great arc on the unit sphere at constant angular speed, giving smooth, professional-looking rotation.

---

## ContinuousRotationAnimation

Drives infinite rotation around an axis. Attach an `AnimationController` in `.repeat()` mode.

```dart
late final AnimationController _spinCtrl = AnimationController(
  vsync: this,
  duration: const Duration(seconds: 4),
)..repeat();

final spin = ContinuousRotationAnimation(
  controller: _spinCtrl,
  axis: Vec3.up,
  radiansPerSecond: math.pi / 2,   // 90°/s = one full revolution per 4 s
);

// In build:
AnimatedBuilder(
  animation: spin,
  builder: (ctx, child) => Transform(
    alignment: Alignment.center,
    transform: Matrix4.identity()
      ..setEntry(3, 2, 0.001)
      ..multiply(Matrix4.rotationY(spin.value.axisAngle.angle)),
    child: child,
  ),
  child: const Globe(),
)
```

---

## FloatAnimation

A sinusoidal `Animation<double>` that produces a smooth up-and-down offset.

```dart
late final AnimationController _floatCtrl = AnimationController(
  vsync: this,
  duration: const Duration(milliseconds: 2000),
)..repeat(reverse: true);

final float = FloatAnimation(
  controller: _floatCtrl,
  amplitude: 10.0,     // maximum displacement in logical pixels
  frequency: 1.0,      // full cycles per animation period
);

AnimatedBuilder(
  animation: float,
  builder: (ctx, child) => Transform.translate(
    offset: Offset(0, float.value),
    child: child,
  ),
  child: const FloatingIcon(),
)
```

---

## FlipAnimation

An `Animation<double>` in `[0, π]` used internally by `FlipCard3D` and `IconButton3D`. It adds a mid-point visibility switch:

- Angle in `[0, π/2)` → front face visible
- Angle in `[π/2, π]` → back face visible (back widget is pre-mirrored)

You can use it directly to implement custom flip widgets:

```dart
final flipAnim = FlipAnimation(
  controller: _ctrl,
  curve: Curves.easeInOut,
);

AnimatedBuilder(
  animation: flipAnim,
  builder: (ctx, _) {
    final angle = flipAnim.value;
    final showFront = angle < math.pi / 2;
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateY(showFront ? angle : angle - math.pi),
      child: showFront ? frontWidget : backWidget,
    );
  },
)
```

---

## Spring3D

Physics-based spring animation.  Instead of specifying a duration and curve, you describe the mechanical properties of a spring (stiffness and damping).

```dart
const Spring3D({
  double stiffness = 200,
  double damping   = 20,
})
```

### Built-in Presets

| Preset | Stiffness | Damping | Character |
|--------|-----------|---------|-----------|
| `Spring3D.snappy` | 500 | 30 | Fast, tight, professional |
| `Spring3D.bouncy` | 200 | 10 | Fun, overshoots slightly |
| `Spring3D.gentle` | 100 | 18 | Smooth, subtle, content-heavy UIs |
| `Spring3D.stiff` | 800 | 60 | Near-instant, snappy feedback |

### Tuning Guide

```
Critical damping ≈ 2 × √(stiffness)
```

| stiffness | Critical damping |
|-----------|-----------------|
| 100 | ~20 |
| 200 | ~28 |
| 500 | ~45 |
| 800 | ~57 |

- **Below critical damping** → overshoots (bouncy feel).
- **At critical damping** → no overshoot, fastest settle.
- **Above critical damping** → sluggish (overdamped).

### Usage with AnimationController

```dart
late final AnimationController _ctrl = AnimationController(
  vsync: this,
  duration: const Duration(milliseconds: 600),
);

Transform3D _from = Transform3D.identity;
Transform3D _to   = Transform3D.identity;

void _springTo(Transform3D target) {
  _from = /* current value from anim */;
  _to   = target;
  _ctrl.forward(from: 0);
}

late final Animation<Transform3D> _anim = Spring3D.bouncy.animate(
  controller: _ctrl,
  from: _from,
  to:   _to,
);
```

### SpringTransform3D Convenience Widget

If you just want "spring to a target whenever it changes", use this widget instead of managing a controller:

```dart
SpringTransform3D(
  targetTransform: _isDragging ? _dragTransform : Transform3D.identity,
  spring: Spring3D.gentle,
  perspective: 800,
  child: MyCard(),
)
```

Whenever `targetTransform` changes, the widget automatically starts a new spring animation from the current position.

---

## Composing Animations

### TweenSequence with Transform3DTween

```dart
final seq = TweenSequence<Transform3D>([
  TweenSequenceItem(
    tween: Transform3DTween(
      begin: Transform3D.identity,
      end:   Transform3D.translated(const Vec3(0, -40, 0)),
    ),
    weight: 40,
  ),
  TweenSequenceItem(
    tween: Transform3DTween(
      begin: Transform3D.translated(const Vec3(0, -40, 0)),
      end:   Transform3D.translated(const Vec3(0, -40, 0)).copyWith(
        rotation: Quat.axisAngle(Vec3.up, math.pi),
      ),
    ),
    weight: 60,
  ),
]);

final anim = seq.animate(_ctrl);
```

### Stagger with Interval

```dart
// Button 1 starts at 0%, completes at 40%
final anim1 = Transform3DTween(begin: hidden, end: visible).animate(
  CurvedAnimation(
    parent: _ctrl,
    curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
  ),
);

// Button 2 starts at 20%, completes at 60%
final anim2 = Transform3DTween(begin: hidden, end: visible).animate(
  CurvedAnimation(
    parent: _ctrl,
    curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
  ),
);
```

---

## Implicit Animation: AnimatedTransform3D

A drop-in implicitly animated `Transform` widget, similar to `AnimatedContainer`:

```dart
AnimatedTransform3D(
  transform: _currentTransform,
  duration:  const Duration(milliseconds: 400),
  curve:     Curves.easeInOut,
  child:     MyWidget(),
)
```

Whenever `transform` changes, the widget automatically tweens to the new value.

---

## Performance Notes

- Keep `AnimationController` disposal in `dispose()` — leaked controllers cause memory and CPU waste.
- Prefer `AnimatedBuilder` over `setState` in animation listeners to minimise subtree rebuilds.
- For objects that spin continuously, use `ContinuousRotationAnimation` with a `RepaintBoundary` so only the rotating widget repaints.
- `SpringTransform3D` creates an `AnimationController` internally. If you have hundreds of simultaneously springing objects, manage controllers manually and share tickers via `TickerProviderStateMixin`.
