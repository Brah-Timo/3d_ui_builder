# Performance Guide

This page documents best practices for keeping `three_d_ui_builder` widgets running at a smooth 60 fps (or 120 fps on ProMotion displays).

---

## Understanding the Cost Model

Every 3D widget in this library ultimately produces a **Flutter `Transform` widget** wrapping a `Matrix4`. The GPU cost of a `Matrix4` transform is near zero — modern GPUs can apply billions of matrix transforms per second.

The real performance budget is in **Flutter's widget rebuild cost** (CPU) and **layer compositing** (GPU memory bandwidth).

### Hierarchy of Costs (cheapest to most expensive)

| Operation | Cost | Notes |
|-----------|------|-------|
| Reading `anim.value` in `AnimatedBuilder` | ~0 | Pure math |
| `Matrix4` transform on a single widget | ~0 | GPU layer transform |
| Rebuilding an `AnimatedBuilder` subtree | Low | Only marks dirty, skips parent |
| `CustomPainter.paint()` call | Medium | Skia draw calls |
| `RepaintBoundary` layer upload | Medium | Texture upload on change |
| `BackdropFilter` (frosted glass) | High | Full render-pass |
| Widget tree rebuild of full screen | Very High | Should never happen per frame |

---

## Rule 1: Use AnimatedBuilder, Not setState

❌ Slow — rebuilds the whole widget including children:

```dart
_ctrl.addListener(() => setState(() {}));
```

✅ Fast — only rebuilds the animated subtree:

```dart
AnimatedBuilder(
  animation: _ctrl,
  builder: (ctx, child) => Transform(
    transform: _anim.value.toMatrix4Perspective(),
    alignment: Alignment.center,
    child: child,         // ← `child` is not rebuilt each frame
  ),
  child: const MyExpensiveWidget(),   // ← built once, reused
)
```

---

## Rule 2: Wrap Animated Widgets in RepaintBoundary

A `RepaintBoundary` promotes the subtree to its own GPU layer. While the animation plays, only that layer is composited — the rest of the screen doesn't repaint.

```dart
RepaintBoundary(
  child: FloatingAction3D(
    icon: Icons.add,
    onPressed: () {},
  ),
)
```

**When RepaintBoundary helps:**

- Continuously animating elements (auto-rotating `CircularList3D`, floating labels).
- Elements that animate but whose siblings are static.

**When it hurts:**

- Elements that are cheap to repaint but rarely animate — the extra layer upload is wasted.
- Very small widgets — the overhead of promoting to a layer exceeds the savings.

---

## Rule 3: CircularList3D Item Count Guidelines

`CircularList3D` depth-sorts items every frame. The sort is `O(n log n)`.

| Item count | Recommended? | Notes |
|------------|-------------|-------|
| 1 – 12 | ✅ Excellent | Typical use case |
| 13 – 30 | ✅ Good | Monitor on low-end devices |
| 31 – 60 | ⚠️ Caution | Profile on target hardware |
| 60+ | ❌ Avoid | Use virtualised list instead |

Each item in the ring is a full Flutter widget sub-tree. If each item is itself complex (e.g., a `Card` with images and text), the total build cost multiplies.

**Mitigation for complex items:**

```dart
CircularList3D(
  itemCount: 20,
  itemBuilder: (ctx, i) => RepaintBoundary(   // ← isolate each item
    child: MyComplexCard(items[i]),
  ),
)
```

---

## Rule 4: Avoid BackdropFilter in Scrolling or Animated Contexts

`Material3D.frostedGlass` sets `isFrosted: true`, which signals the widget that a `BackdropFilter` (blur) should be applied. This is one of Flutter's most expensive operations because it forces a full off-screen render pass.

**Guideline:** Use frosted glass only on static or infrequently animated overlays (modals, tooltips, pause screens). Never use it in a scrolling list or continuously animated widget.

```dart
// ✅ Good — frosted glass on a static modal
Panel3D(
  material: Material3D.frostedGlass(),
  child: const AlertContent(),
)

// ❌ Bad — frosted glass in a fast-rotating ring
CircularList3D(
  itemBuilder: (ctx, i) => Panel3D(
    material: Material3D.frostedGlass(),  // expensive × N items × 60 fps
    child: items[i],
  ),
)
```

---

## Rule 5: Profile Before Optimising

Use Flutter DevTools to identify actual bottlenecks:

```sh
flutter run --profile
# Then open DevTools → Performance tab
```

Key metrics:

| Metric | Target |
|--------|--------|
| Frame build time | < 8 ms (120 fps) or < 16 ms (60 fps) |
| Frame raster time | < 8 ms |
| `AnimatedBuilder` rebuild count per frame | Should match the number of animating nodes |
| Skipped frames | 0 in steady state |

---

## Rule 6: Dispose AnimationControllers

Every `AnimationController` holds a `Ticker` that runs every vsync. Leaking a controller means it keeps calling your listener on every frame for the lifetime of the app.

```dart
class _MyState extends State<My> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(vsync: this, ...);

  @override
  void dispose() {
    _ctrl.dispose();   // ← always required
    super.dispose();
  }
}
```

---

## Rule 7: Spring3D Controller Duration

`Spring3D.animate()` requires an `AnimationController`. Set its `duration` to cover the spring's settle time, not longer:

| Spring preset | Recommended duration |
|---------------|---------------------|
| `Spring3D.snappy` | 400 ms |
| `Spring3D.bouncy` | 700 ms |
| `Spring3D.gentle` | 900 ms |
| `Spring3D.stiff` | 200 ms |

If the duration is too short, the animation stops before the spring settles (visible jump at the end). Too long wastes controller cycles after the spring is already at rest.

---

## Rule 8: Use const Constructors for Child Widgets

Widgets that don't change should be `const` so Flutter can skip rebuilding them entirely:

```dart
FlipCard3D(
  front: const FrontContent(),   // ← const: zero rebuild cost
  back:  const BackContent(),
)
```

---

## Rule 9: Limit Concurrent Spring Animations

Each `SpringTransform3D` widget internally creates an `AnimationController` + `SpringSimulation`. Having more than ~20 simultaneous spring animations on screen at once can cause CPU spikes on low-end devices.

**Solution:** Batch updates or use a single controller for multiple objects when they share the same motion.

---

## Benchmarking Widget Costs

Run the included benchmark (Flutter >= 3.24):

```sh
cd example
flutter drive --driver=test_driver/perf_driver.dart --target=test_driver/scroll_perf.dart --profile
```

Or use Flutter's built-in `WidgetInspector` → **Performance Overlay** to visualise frame timings in real time.
