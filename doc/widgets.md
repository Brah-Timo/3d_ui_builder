# Widget Reference

Complete API documentation for every widget in `three_d_ui_builder`.

---

## Buttons

### ThreeDButton

A button with a real 3D depth slab that physically presses in when tapped.

**Constructor**

```dart
ThreeDButton({
  required Widget label,
  VoidCallback? onPressed,
  double depth           = 6.0,
  Color  faceColor       = const Color(0xFF5C6BC0),
  Color? sideColor,              // auto-derived from faceColor if omitted
  double borderRadius    = 12.0,
  EdgeInsets padding     = const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
  bool   showHighlight   = true,
  Duration pressDuration = const Duration(milliseconds: 80),
})
```

**Behaviour**
- On `TapDown` the face travels `depth` pixels toward the viewer.
- On `TapUp` it springs back and fires `onPressed`.
- When `onPressed` is `null` the button renders in a greyed-out disabled state.
- `showHighlight` paints a specular streak across the top-left corner.
- Reads `ThreeDTheme.defaultDepth` from the widget tree.

**Minimal usage**

```dart
ThreeDButton(
  label: const Text('Click'),
  faceColor: Colors.deepPurple,
  onPressed: () => print('tapped'),
)
```

---

### FloatingAction3D

A floating action button with a levitation pulse and dynamic shadow.

```dart
FloatingAction3D({
  required IconData icon,
  required VoidCallback onPressed,
  Color backgroundColor = Colors.blue,
  double size           = 56,
  double pulseRadius    = 8,        // px the button lifts up and down
  Duration pulseDuration = const Duration(milliseconds: 1800),
})
```

---

### IconButton3D

An icon that rotates 180° around the Y-axis on each press, then spring-snaps back.

```dart
IconButton3D({
  required IconData icon,
  required VoidCallback onPressed,
  Color   color    = Colors.blue,
  double  iconSize = 28,
  Duration flipDuration = const Duration(milliseconds: 260),
})
```

---

## Cards

### FlipCard3D

A card with a perspective-correct 3D flip animation between two faces.

```dart
FlipCard3D({
  required Widget front,
  required Widget back,
  Duration flipDuration      = const Duration(milliseconds: 500),
  FlipAxis flipAxis          = FlipAxis.y,
  Curve    curve             = Curves.easeInOut,
  bool     initiallyFlipped  = false,
  double   perspective       = 0.001,
  ValueChanged<bool>? onFlipComplete,
  FlipCard3DController?  controller,
})
```

**FlipAxis values**

| Value | Effect |
|-------|--------|
| `FlipAxis.y` | Horizontal card turn (like flipping a page) |
| `FlipAxis.x` | Vertical top-to-bottom tumble |
| `FlipAxis.z` | Spinning in-plane rotation |

**FlipCard3DController**

```dart
final ctrl = FlipCard3DController();

ctrl.flip();         // flip to opposite face
ctrl.showFront();    // show front (no-op if already showing)
ctrl.showBack();     // show back (no-op if already showing)
ctrl.isFront;        // bool — current state
```

---

### TiltCard

A card that tilts toward the current pointer position or follows the device gyroscope.

```dart
TiltCard({
  required Widget child,
  double maxTiltDegrees = 12.0,
  bool   useGyroscope   = false,   // requires sensors_plus
  double perspective    = 0.001,
  double sensitivity    = 1.0,
})
```

---

### DepthCard

A multi-layer card where each layer is rendered at a different Z depth.

```dart
DepthCard({
  required List<DepthLayer> layers,
  double perspective    = 0.001,
  double hoverAmplitude = 10.0,   // max layer shift on hover (px)
})

// A single layer:
DepthLayer({
  required Widget child,
  required double depth,     // Z offset in logical pixels
})
```

**Example**

```dart
DepthCard(
  layers: [
    DepthLayer(depth:  0, child: BackgroundGradient()),
    DepthLayer(depth: 12, child: ProductImage()),
    DepthLayer(depth: 24, child: PriceLabel()),
  ],
)
```

---

### ParallaxCard

A card where the background image shifts at a fraction of the card's tilt, creating a parallax depth illusion.

```dart
ParallaxCard({
  required ImageProvider background,
  required Widget child,
  double parallaxFactor = 0.25,     // 0 = no parallax, 1 = full
  double maxTiltDegrees = 15,
  double perspective    = 0.001,
  BorderRadius? borderRadius,
})
```

---

## Lists

### CircularList3D

A rotating 3D ring of items with depth-based scale and opacity.

```dart
CircularList3D({
  required int itemCount,
  required IndexedWidgetBuilder itemBuilder,
  double  radius              = 180,
  double  tiltAngle           = 0.3,    // ring tilt in radians
  double  perspective         = 0.001,
  bool    autoRotate          = false,
  double  rotationSpeed       = 0.25,   // full rotations / second
  RotationDirection rotationDirection = RotationDirection.clockwise,
  bool    snapOnRelease       = false,
})
```

**RotationDirection**

```dart
enum RotationDirection { clockwise, counterClockwise }
```

**Depth formula**

Items are scaled by:

```
scale = 0.55 + 0.45 × (z / radius + 1) / 2
```

Items in the back (`z` negative) have `scale ≈ 0.55`; items in the front have `scale ≈ 1.0`.

---

### CylinderList

A scrollable drum/reel list where items curve around a virtual cylinder.

```dart
CylinderList({
  required int itemCount,
  required IndexedWidgetBuilder itemBuilder,
  double cylinderHeight  = 300,
  double itemHeight      = 48,
  double cylinderRadius  = 120,
  double perspective     = 0.001,
})
```

---

### CoverFlow3D

iTunes-style coverflow: the selected item faces forward; neighbours fan out sideways.

```dart
CoverFlow3D({
  required int itemCount,
  required IndexedWidgetBuilder itemBuilder,
  double itemWidth    = 200,
  double itemHeight   = 200,
  double fanAngle     = 55.0,      // degrees rotation of neighbours
  double fanOffset    = 140.0,     // horizontal offset of neighbours (px)
  double perspective  = 0.001,
  ValueChanged<int>? onPageChanged,
})
```

---

### SphereMenu

Menu items distributed over a virtual sphere surface.  Drag to rotate.

```dart
SphereMenu({
  required List<T> items,
  required Widget Function(BuildContext, T) itemBuilder,
  required ValueChanged<T> onItemTap,
  double radius      = 160,
  double perspective = 0.001,
  bool   autoRotate  = false,
})
```

> **Note:** In 0.1.0 the distribution algorithm is simplified. Full Fibonacci sphere packing arrives in 0.2.0.

---

## Containers

### CubeContainer

A fully interactive 3D cube. Each face hosts an independent widget.

```dart
CubeContainer({
  required double size,
  required Widget front,
  required Widget back,
  required Widget left,
  required Widget right,
  required Widget top,
  required Widget bottom,
  double  perspective     = 0.001,
  double  dragSensitivity = 0.01,
  ValueChanged<CubeFace>? onFaceVisible,
  CubeController? controller,
})
```

**CubeController**

```dart
final ctrl = CubeController();
ctrl.showFace(CubeFace.back);     // animates to the back face
ctrl.showFace(CubeFace.top);
```

**CubeFace enum**

```dart
enum CubeFace { front, back, left, right, top, bottom }
```

**Face matrices** (internal reference)

| Face | Translation | Rotation |
|------|-------------|----------|
| front | `(0, 0, +half)` | none |
| back | `(0, 0, −half)` | `rotateY(π)` |
| left | `(−half, 0, 0)` | `rotateY(−π/2)` |
| right | `(+half, 0, 0)` | `rotateY(+π/2)` |
| top | `(0, −half, 0)` | `rotateX(+π/2)` |
| bottom | `(0, +half, 0)` | `rotateX(−π/2)` |

---

### Panel3D

A flat panel with programmable tilt and a dynamic shadow.

```dart
Panel3D({
  required Widget child,
  double    elevation   = 8,
  double    tiltX       = 0.04,    // radians
  double    tiltY       = -0.02,
  Material3D? material,
  double    perspective = 0.001,
  BorderRadius? borderRadius,
})
```

---

### Stack3D

A `Stack` replacement where each child has a configurable Z depth.

```dart
Stack3D({
  required List<Stack3DItem> children,
  double perspective = 0.001,
})

Stack3DItem({
  required Widget child,
  required double depth,    // Z offset in logical pixels
  AlignmentGeometry alignment = Alignment.center,
})
```

---

## Text

### ExtrudedText

Text rendered with a visible 3D extrusion.

```dart
ExtrudedText(
  'HELLO',
  style:       TextStyle(fontSize: 48, fontWeight: FontWeight.w900),
  depth:       6,
  faceColor:   Colors.white,
  sideColor:   Colors.grey.shade400,
  perspective: 0.001,
)
```

> **Limitation in 0.1.0:** Arabic / RTL scripts are not yet supported.

---

### FloatingLabel

A badge/label that hovers above its `child` with a continuous float animation.

```dart
FloatingLabel({
  required Widget  child,
  required String  label,
  Color   color        = Colors.red,
  double  floatHeight  = 8,        // px amplitude
  Duration floatPeriod = const Duration(milliseconds: 2000),
  TextStyle? labelStyle,
})
```

---

## Scene Widgets

### ThreeDSceneWidget

Root widget for multi-object scenes.

```dart
ThreeDSceneWidget({
  required List<Widget> children,    // ThreeDObject widgets
  CameraController? camera,
  List<LightSource> lights = const [],
})
```

---

### CameraController

Describes the virtual camera viewing the scene.

```dart
CameraController({
  Vec3  position = const Vec3(0, -100, 600),
  Vec3  target   = Vec3.zero,
  double fov     = 60,       // field-of-view in degrees
  double near    = 1,
  double far     = 10000,
})
```

---

### LightSource

```dart
LightSource.directional({
  required Vec3  direction,
  Color   color     = Colors.white,
  double  intensity = 1.0,
})

LightSource.point({
  required Vec3  position,
  Color   color     = Colors.white,
  double  intensity = 1.0,
  double  radius    = 400,
})

LightSource.ambient({
  Color   color     = Colors.white,
  double  intensity = 0.3,
})
```
