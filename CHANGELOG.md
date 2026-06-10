# Changelog

All notable changes to `three_d_ui_builder` are documented in this file.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).  
Versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Planned
- `SphereMenu` — full Fibonacci sphere packing for evenly distributed menu items
- `ExtrudedText` — Arabic / RTL font support
- Deep `flutter_scene` integration for glTF avatar embedding
- Shader-based frosted glass, neon glow, and hologram visual effects
- Theme packs: Glassmorphism, Cyberpunk, Minimal 3D

---

## [0.1.0] — 2026-06-10

Initial release of `three_d_ui_builder`.

### Added

#### Core Math (`src/core/math/`)
- **`Vec3`** — Immutable, value-type 3D vector with full arithmetic (`+`, `-`, `*`, `/`, unary `-`), geometric operations (`dot`, `cross`, `normalized`, `reflect`), linear interpolation (`lerp`), distance, clamp, and `copyWith`. Named constants: `zero`, `one`, `right`, `up`, `forward`, `left`, `down`, `back`.
- **`Quat`** — Immutable unit quaternion for 3D rotations. Factory constructors: `axisAngle`, `euler`, `fromToRotation`. Operations: Hamilton product (`*`), `conjugate`, `inverse`, `rotate(Vec3)`. Static interpolation: `slerp` (spherical linear, shortest-arc, constant-speed). Decomposition via `axisAngle` named record.
- **`Transform3D`** — Immutable composite transform (position `Vec3` + rotation `Quat` + scale `Vec3`). Converts to `Matrix4` via `toMatrix4()` and `toMatrix4Perspective(depth)`. Interpolates with `lerp` (SLERP for rotation). Composes transforms with `compose`. Named constructors: `identity`, `translated`, `rotated`, `scaled`. `copyWith` support.
- **`Transform3DTween`** — `Tween<Transform3D>` that uses `lerp` (with SLERP for rotation). Plugs directly into Flutter's `AnimationController`.
- **`Matrix4Ext`** — Extension methods on `Matrix4`: `withPerspective(depth)`, `trs(position, rotation, scale)`.

#### Core Foundation (`src/core/foundation/`)
- **`ThreeDObject`** — Base data model for any object in a 3D scene. Holds `transform`, `material`, `id`, and `isVisible` flag.
- **`ThreeDScene`** — Scene manager that holds a list of `ThreeDObject` instances. Provides `add`, `remove`, `findById`, and `sorted` (depth-sorted back-to-front) access.
- **`DepthSorter`** — Utility that sorts a list of `ThreeDObject` by their world Z position relative to a camera direction using a painter's algorithm.

#### Core Engine (`src/core/engine/`)
- **`SceneRenderer`** — High-level `StatefulWidget` that accepts a `ThreeDScene` and renders it by delegating each visible object to its own `Transform` widget.
- **`RenderPipeline`** — Manages the render cycle: culls invisible objects, depth-sorts via `DepthSorter`, and computes per-object `Matrix4` transforms with perspective.
- **`CanvasBridge`** — Bridges the Flutter `Canvas` 2D painting API with the 3D transform stack, enabling `CustomPainter`-based widgets to participate in the scene.

#### Widgets — Buttons (`src/widgets/buttons/`)
- **`ThreeDButton`** — Button with a real 3D depth slab (face + side) painted by `CustomPainter`. Presses in on `TapDown` via `AnimationController`, releases on `TapUp` with `Curves.easeOut`. Optional specular highlight streak. Reads `defaultDepth` from `ThreeDTheme`.
- **`FloatingAction3D`** — Extended `FloatingActionButton` with a continuous levitation pulse animation and drop shadow that oscillates with the button position.
- **`IconButton3D`** — Icon that performs a 180° Y-axis rotation on each press using `FlipAnimation`, then returns to rest with a spring settle.

#### Widgets — Cards (`src/widgets/cards/`)
- **`FlipCard3D`** — Card with perspective-correct flip between `front` and `back` widgets. Flip axis configurable (`FlipAxis.x/y/z`). `FlipCard3DController` for programmatic control (`flip`, `showFront`, `showBack`). `onFlipComplete` callback.
- **`TiltCard`** — Card that tilts to follow pointer position (mouse/touch). Optional gyroscope mode (`useGyroscope: true`) using `sensors_plus`. Configurable `maxTiltDegrees` and `perspective`.
- **`DepthCard`** — Multi-layer card where each `DepthLayer` renders at a different Z offset. Pointer hover translates layers at different rates to produce depth parallax.
- **`ParallaxCard`** — Card with a background image that scrolls at `parallaxFactor` speed relative to the foreground content as the card is tilted.

#### Widgets — Lists (`src/widgets/lists/`)
- **`CircularList3D`** — Carousel on a 3D ring. Items are scaled (`0.55..1.0`) and faded (`0.4..1.0`) by Z depth. Horizontal drag rotates the ring. `autoRotate` with configurable `rotationSpeed` and `rotationDirection`. `snapOnRelease` for slot-style snapping. Depth-sorted back-to-front rendering.
- **`CylinderList`** — Drum/slot-machine list. Items are positioned on the curved surface of a cylinder and rotate into the viewport on scroll.
- **`CoverFlow3D`** — iTunes CoverFlow-style page view. Selected item faces forward; neighbours fan out on each side with increasing Y-rotation and depth offset.
- **`SphereMenu`** — Menu items distributed across a sphere surface. Dragging rotates the sphere. Items scale and fade by depth. (Beta: uses simplified distribution in 0.1.0; Fibonacci packing arriving in 0.2.0.)

#### Widgets — Containers (`src/widgets/containers/`)
- **`CubeContainer`** — Six-faced 3D cube. Each face is a `Widget` rendered via `Transform` with correctly computed face matrices (front, back, left, right, top, bottom). Free-drag rotation with `onPanUpdate`. `CubeController.showFace(CubeFace)` for animated face navigation. `onFaceVisible` callback.
- **`Panel3D`** — Flat panel with programmable X/Y tilt and a dynamic drop shadow calculated from `ThreeDTheme.lightPosition`. Accepts `Material3D` for surface appearance.
- **`Stack3D`** — Replacement for `Stack` where each child is wrapped in a `Stack3DItem` with a `depth` value. Children are positioned with increasing Z translation and slight perspective scaling.

#### Widgets — Text (`src/widgets/text/`)
- **`ExtrudedText`** — Renders text with a visible depth extrusion. Uses `CustomPainter` to draw N offset copies of the text path in `sideColor` then the face copy in `faceColor`. Supports all `TextStyle` properties.
- **`FloatingLabel`** — A label that performs a continuous float animation above its `child`. The float is driven by `FloatAnimation` with configurable `amplitude` and `frequency`.

#### Widgets — Scene (`src/widgets/scene/`)
- **`ThreeDSceneWidget`** — Root container for complex multi-object scenes. Accepts a `CameraController` and a list of `LightSource` objects. Propagates lighting context to all child `ThreeDObject` widgets.
- **`CameraController`** — Configures the virtual camera: `position`, `target`, `fov`, `near`, and `far` clip planes. Computes the view-projection matrix.
- **`LightSource`** — Represents a scene light. Named constructors: `directional`, `point`, `ambient`. Properties: `color`, `intensity`, `direction`/`position`.

#### Animation (`src/animation/`)
- **`Transform3DTween`** — (see Core Math above)
- **`RotationAnimation`** — `Animation<Quat>` using `Quat.slerp`. Accepts a `Curve`. Takes the shortest rotational arc automatically.
- **`ContinuousRotationAnimation`** — Infinite spinning `Animation<Quat>` driven by an `AnimationController` in repeat mode. Configurable `axis` and `radiansPerSecond`.
- **`FloatAnimation`** — Sinusoidal `Animation<double>` (Y offset). Configurable `amplitude` (pixels) and `frequency` (Hz).
- **`FlipAnimation`** — `Animation<double>` in `[0, π]` with automatic face-switch detection at `π/2`. Used internally by `FlipCard3D` and `IconButton3D`.
- **`Spring3D`** — Physics-based spring factory. Uses `SpringSimulation` from `flutter/physics.dart`. Static presets: `snappy`, `bouncy`, `gentle`, `stiff`. Returns `Animation<Transform3D>`.
- **`SpringTransform3D`** — Convenience `StatefulWidget` that auto-springs to `targetTransform` whenever it changes.

#### Gestures (`src/gestures/`)
- **`Drag3DRecognizer`** — Wraps a child in a `GestureDetector` and converts 2D drag deltas into 3D rotation `Quat` deltas via `Quat.axisAngle`. Sensitivity configurable.
- **`PinchDepthRecognizer`** — Maps pinch scale factor to a Z-axis depth change. `onDepthChange(double scale)` callback.
- **`GyroscopeTilt`** — Subscribes to `sensors_plus` gyroscope stream and converts angular velocity to `tiltX`/`tiltY` values fed to a builder function.

#### Painters (`src/painters/`)
- **`ShadowPainter3D`** — `CustomPainter` that draws a dynamic drop shadow whose offset and blur are computed from `ThreeDTheme.lightPosition` relative to the widget's 3D position.
- **`EdgePainter`** — `CustomPainter` that draws visible edges of a 3D shape using projected 2D line segments. Used by `CubeContainer` and `Panel3D` for edge highlights.
- **`ReflectionPainter`** — `CustomPainter` that renders a blurred, opacity-reduced reflection below a widget to simulate a reflective floor surface.

#### Theme (`src/theme/`)
- **`ThreeDTheme`** — `InheritedWidget` that propagates `ThreeDThemeData` down the tree. `ThreeDTheme.of(context)` falls back to `ThreeDThemeData.defaults()`.
- **`ThreeDThemeData`** — Immutable theme data. Fields: `defaultDepth`, `defaultMaterial`, `shadowStyle`, `enableLighting`, `lightPosition`, `perspective`. Presets: `defaults()`, `cyberpunk()`, `neumorphic()`.
- **`Material3D`** — Immutable surface description: `color`, `metalness`, `roughness`, `opacity`, `isFrosted`. Named presets: `matte`, `glossyPlastic`, `metallic`, `frostedGlass`, `rubber`. Derived colour helpers: `highlightColor`, `shadowColor`.
- **`DepthShadowStyle`** — Enum: `soft` (Gaussian-blurred shadow), `sharp` (hard-edge shadow), `colored` (shadow tinted from light colour).

#### Utilities (`src/utils/`)
- **`PerspectiveUtils`** — Static helpers: `project(Vec3 point, double focalLength)` → `Offset`, `depthScale(double z, double radius)`, `perspectiveMatrix(double depth)`.
- **`HitTest3D`** — Determines whether a 2D screen point intersects a 3D bounding rectangle given its `Transform3D`. Used to implement tap handling on rotated/translated widgets.
- **`DebugOverlay`** — Development-mode overlay that draws X/Y/Z axis gizmos and bounding-box wireframes on top of any widget. Enabled via `ThreeDDebugConfig.enabled = true`.

#### Example App (`example/`)
- Five demo screens showcasing all widget families: `DemoButtons`, `DemoCards`, `DemoCircularList`, `DemoCubeScene`, `DemoSphereMenu`.

#### Documentation (`doc/`)
- `getting_started.md` — Installation, first widget, ThreeDTheme setup
- `widgets.md` — Complete widget reference with parameters and examples
- `math.md` — Vec3, Quat, Transform3D API reference and math background
- `animation.md` — All animation classes, spring presets, tween usage
- `theming.md` — ThreeDTheme, Material3D, DepthShadowStyle reference
- `gestures.md` — Drag, pinch, gyroscope gesture system
- `architecture.md` — Package design decisions, render pipeline explanation
- `performance.md` — Best practices, widget count guidelines, profiling tips
- `contributing.md` — How to contribute, code style, test requirements
- `migration.md` — Migration notes from `flutter_3d` and `flutter_scene`

---

### Known Limitations in 0.1.0

- `SphereMenu` uses simplified item distribution (not full Fibonacci packing). Uneven spacing may be visible with > 20 items.
- Dynamic shadows in `ShadowPainter3D` are approximate (2D projection, not ray-traced). Complex overlapping objects may show shadow artefacts.
- `ExtrudedText` does not yet support Arabic / RTL scripts — the extrusion direction is always left-to-right.
- macOS, Windows, and Linux require `--enable-impeller` flag for best results.
- `GyroscopeTilt` is a no-op on platforms without a gyroscope (Web, Desktop). A pointer-based fallback is used automatically.

---

[Unreleased]: https://github.com/your-org/3d_ui_builder/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/your-org/3d_ui_builder/releases/tag/v0.1.0
