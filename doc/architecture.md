# Architecture

This document explains the design decisions behind `three_d_ui_builder`, how the render pipeline works, and why certain tradeoffs were made.

---

## Design Philosophy

### Flutter-Native, Not OpenGL-Wrapping

The core principle of `three_d_ui_builder` is: **3D effects should feel like Flutter, not like a game engine embedded in Flutter**.

This means:
- Widget API uses the same constructors, named parameters, and callback conventions as `StatefulWidget`s in the Material library.
- No user-facing `Scene` objects, no `Node` trees, no GPU resource management.
- Animations use `AnimationController` and `Tween`, not custom timelines.
- Theming uses `InheritedWidget`, not a global singleton.

### 2.5D vs True 3D

The library deliberately operates in what you might call **2.5D**: it uses Flutter's `Matrix4.Transform` pipeline (which is ultimately a CSS3D-style perspective transform) rather than a true 3D scene graph with depth buffer, backface culling, and per-pixel lighting.

**Benefits of this approach:**

| Benefit | Detail |
|---------|--------|
| Zero dependencies on Impeller features | Works on stable channel without flags |
| All widgets are Flutter widgets | Full hit-testing, accessibility, `RepaintBoundary`, etc. |
| Arbitrary Flutter content on every surface | `CubeContainer` can put a live `TextField` on any face |
| Works on Web (CanvasKit) without WebGL | Pure Dart + Skia |

**Limitations:**

- No true Z-buffer — overlapping objects require manual depth sorting.
- Shadows are approximated (2D projection), not ray-traced.
- Reflections and refractions are pre-baked visual effects, not computed from geometry.

For applications that genuinely need a full 3D scene graph (game environments, glTF model viewers), use `flutter_scene` directly. `three_d_ui_builder` is designed for **UI**, not 3D world simulation.

---

## Layer Diagram

```
┌─────────────────────────────────────────────────────┐
│               Your Application Code                  │
│          ThreeDButton  FlipCard3D  CubeContainer     │
└───────────────────────────┬─────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────┐
│              Widget Layer  (src/widgets/)             │
│   StatefulWidgets + GestureDetectors + CustomPainter │
│         All public, all Flutter-style API            │
└──────────────────┬─────────────────┬────────────────┘
                   │                 │
┌──────────────────▼──────┐ ┌────────▼────────────────┐
│   Animation Layer        │ │    Theme Layer           │
│   (src/animation/)       │ │    (src/theme/)          │
│   Spring3D, Tween3D,     │ │    ThreeDTheme           │
│   RotationAnimation      │ │    Material3D            │
└──────────────────┬───────┘ └─────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────────┐
│             Core Math Layer  (src/core/math/)         │
│           Vec3   Quat   Transform3D   Matrix4Ext      │
└─────────────────────────────────────────────────────┘
```

---

## Core Math Layer

### Vec3

Chosen as a first-class immutable value type (not wrapping `vector_math`'s mutable `Vector3`) because:
- Flutter's widget system is built on immutability — immutable math objects compose cleanly.
- `Transform3D` is `@immutable` and used as a `Tween` value, requiring safe equality.
- `vector_math`'s `Vector3` overrides `==` by reference, not value — not usable as a map key.

### Quat

Quaternions over Euler angles because:
- No Gimbal Lock at any orientation.
- `slerp` produces constant-speed, shortest-arc rotation — critical for fluid animation.
- Quaternion composition (`*` operator) accumulates rotations without drift.

### Transform3D

A single type that unifies position + rotation + scale. This mirrors `RenderObject.paintTransform` and makes it trivial to pass a full 3D state to a single `Tween`.

---

## Render Pipeline

### Per-Widget Pipeline (Buttons, Cards, Panels)

```
1. AnimationController.value (0.0 → 1.0)
      ↓
2. Transform3DTween.lerp(t)   or   Spring3D.animate(...)
      ↓
3. Transform3D.toMatrix4Perspective()
      ↓
4. Flutter Transform(transform: matrix4, alignment: Alignment.center, child: ...)
      ↓
5. Flutter's existing compositing + Skia/Impeller rendering
```

The perspective entry `matrix[3][2] = 1/d` makes objects at `z > 0` appear larger and objects at `z < 0` appear smaller, creating the depth illusion.

### Scene Pipeline (CircularList3D, CubeContainer)

```
1. User gesture or auto-rotation updates angle/rotX/rotY state
      ↓
2. Per-item position calculated: (x, y, z) from parametric ring/cube formula
      ↓
3. Items sorted back-to-front by z (painter's algorithm)
      ↓
4. Each item wrapped in:
       Positioned(left, top, child:
         Opacity(opacity,
           child: Transform(scale matrix, child: item)))
      ↓
5. All wrapped in a SizedBox + Stack
```

The depth sort ensures that front items visually overlap back items correctly. Without sorting, items at the back would render on top of front items when their Positioned rects overlap.

---

## Depth Sorting Algorithm

`DepthSorter` uses a straightforward painter's algorithm:

```dart
objects.sort((a, b) => a.worldZ.compareTo(b.worldZ));
// Back items first → front items paint over them
```

This is `O(n log n)` and sufficient for UI element counts (< 100 items). For large point clouds or complex scenes where objects can overlap in 3D in non-trivial ways, a BSP tree or Z-buffer would be needed — but those use cases are outside the scope of this library.

---

## Animation Architecture

### Why Flutter's AnimationController?

Using the standard Flutter animation framework instead of a custom ticker means:
- `vsync: this` prevents offscreen animation, saving battery.
- Integrates with `TickerMode` so animations pause when the widget is hidden.
- `AnimatedBuilder` only rebuilds the affected subtree.
- Works with all existing Flutter tools: `AnimationInspector`, `slow animations` mode, etc.

### Spring3D Implementation

```dart
class _Spring3DAnimation extends Animation<Transform3D>
    with AnimationWithParentMixin<double> {

  @override
  Transform3D get value {
    final sim = SpringSimulation(description, 0, 1, 0);
    final t   = sim.x(controller.value).clamp(0.0, 1.0);
    return from.lerp(to, t);
  }
}
```

`SpringSimulation.x(t)` maps the raw controller time `[0, 1]` to a physically simulated position. The result is clamped to `[0, 1]` and used as the lerp factor between `from` and `to` transforms.

**Note:** `SpringSimulation` from `flutter/physics.dart` computes the position analytically (not numerically), so it's deterministic and has no integration error.

---

## Widget Lifecycle

### FlipCard3D

```
initState()
  → creates AnimationController (value = 0 or 1 if initiallyFlipped)
  → binds controller

flip()
  → if _isFront: ctrl.forward() → setState _isFront=false → onFlipComplete(false)
  → else:        ctrl.reverse() → setState _isFront=true  → onFlipComplete(true)

build()
  → AnimatedBuilder(animation: CurvedAnimation)
    → angle = anim.value × π
    → if angle < π/2: render front with rotateY(angle)
    → else:           render back  with rotateY(angle − π)

dispose()
  → ctrl.dispose()
```

The back widget is rendered with `rotateY(angle − π)` instead of `rotateY(angle)` so it appears right-reading (not mirror-flipped) when the card is showing its back.

### CubeContainer

The cube is rendered as six `Transform`+`SizedBox` children in a `Stack`. Each face has a fixed `Matrix4` that places it on the correct face of the cube. The outer `Transform` applies the user's `rotX`/`rotY` rotation. The full transform chain for, say, the left face is:

```
Outer transform (rotX, rotY)  ×  Left face matrix (translate(−half) × rotateY(−π/2))
```

This separates "how the cube is oriented in space" from "where each face sits on the cube", keeping the math clean and the matrices simple.

---

## Memory Management

- Every `AnimationController` is disposed in `dispose()` of its owning `State`.
- `GyroscopeTilt` cancels its `sensors_plus` stream subscription in `dispose()`.
- `ThreeDScene` holds `ThreeDObject` references; objects are removed via `scene.remove(id)`. No automatic garbage collection beyond normal Dart GC.
- `DebugOverlay` is always `const`-constructible and its paint calls are guarded by `if (kDebugMode)` — zero overhead in release builds.

---

## Testing Strategy

| Layer | Approach |
|-------|----------|
| Math (`Vec3`, `Quat`, `Transform3D`) | Pure Dart unit tests — no Flutter needed |
| Animation (`RotationAnimation`, `Spring3D`) | `testWidgets` with `tester` as `TickerProvider` |
| Widgets (`FlipCard3D`, `ThreeDButton`, `CircularList3D`) | `testWidgets` — pump, gesture simulation, `pumpAndSettle` |
| Visual correctness | `golden_toolkit` golden tests (optional, in CI only) |

All tests use real implementations — no mock data, no fake widgets, no stub animation controllers.
