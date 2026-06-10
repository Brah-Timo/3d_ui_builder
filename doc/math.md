# Math Primitives

`three_d_ui_builder` exposes its internal math layer as a public API.  You can use these types to build custom 3D widgets or integrate with other packages.

---

## Vec3

An **immutable**, value-type 3D vector.

```dart
import 'package:three_d_ui_builder/three_d_ui_builder.dart';

const a = Vec3(1, 2, 3);
```

### Named Constants

| Constant | Value | Meaning |
|----------|-------|---------|
| `Vec3.zero` | `(0, 0, 0)` | Origin |
| `Vec3.one` | `(1, 1, 1)` | Unit all |
| `Vec3.right` | `(1, 0, 0)` | Positive X |
| `Vec3.up` | `(0, −1, 0)` | Negative Y (Flutter Y-axis is inverted) |
| `Vec3.forward` | `(0, 0, 1)` | Positive Z |
| `Vec3.left` | `(−1, 0, 0)` | Negative X |
| `Vec3.down` | `(0, 1, 0)` | Positive Y |
| `Vec3.back` | `(0, 0, −1)` | Negative Z |

### Constructors

```dart
Vec3(double x, double y, double z)
Vec3.all(double value)   // Vec3(v, v, v)
```

### Arithmetic Operators

```dart
a + b          // component-wise addition
a - b          // component-wise subtraction
a * scalar     // scalar multiplication
a / scalar     // scalar division (asserts scalar != 0)
-a             // negation
```

All operators return a **new** `Vec3` — nothing is mutated.

### Geometric Operations

```dart
double dot(Vec3 other)         // dot product: a.x*b.x + a.y*b.y + a.z*b.z
Vec3   cross(Vec3 other)       // cross product (right-hand rule)
Vec3   get normalized          // unit vector (safe: returns zero if length < 1e-10)
double get length              // Euclidean length: √(x²+y²+z²)
double get lengthSquared       // length² (no sqrt — fast for comparison)
double distanceTo(Vec3 other)  // Euclidean distance
Vec3   lerp(Vec3 other, double t)  // linear interpolation, t ∈ [0, 1]
Vec3   reflect(Vec3 normal)    // reflection around a normal
Vec3   clamp(double min, double max)  // per-component clamp
Vec3   copyWith({double? x, double? y, double? z})
```

### Equality & Hashing

`Vec3` implements `==` by component equality and `hashCode` via `Object.hash(x, y, z)`.  It is safe to use as a `Map` key or in a `Set`.

---

## Quat

An **immutable** unit quaternion representing a 3D rotation.

Quaternions avoid the **Gimbal Lock** problem inherent in Euler angles.  They represent orientations as a point on the 4D unit sphere, which makes interpolation (`slerp`) constant-speed and artefact-free.

```
Quaternion: q = (x, y, z, w)
where (x, y, z) is the imaginary/vector part
and    w        is the real/scalar part
```

### Named Constants

```dart
Quat.identity   // Quat(0, 0, 0, 1) — represents no rotation
```

### Factory Constructors

```dart
// Rotation of angleRadians around axis (axis need not be normalised)
Quat.axisAngle(Vec3 axis, double angleRadians)

// From Euler angles (pitch, yaw, roll) in ZYX order
Quat.euler(double pitch, double yaw, double roll)

// Rotation that turns `from` direction into `to` direction
Quat.fromToRotation(Vec3 from, Vec3 to)
```

### Properties

```dart
double get magnitude          // should be ≈ 1 for unit quaternions
double get magnitudeSquared   // faster, avoids sqrt
Quat   get normalized         // returns unit quaternion copy
Quat   get conjugate          // (−x, −y, −z, w)
Quat   get inverse            // conjugate.normalized (equals conjugate for unit quats)
```

### Operators

```dart
Quat operator *(Quat other)   // Hamilton product — compose two rotations
                              // NOTE: quaternion multiplication is NOT commutative
```

### Static Methods

#### `Quat.slerp(Quat a, Quat b, double t)`

Spherical linear interpolation.

- `t = 0.0` → returns `a`
- `t = 1.0` → returns `b`
- `t = 0.5` → midpoint rotation at constant angular speed
- Automatically takes the **shortest arc** (negates `b` when dot product < 0)
- Falls back to normalised lerp when quaternions are nearly identical (dot > 0.9995)

**Formula:**

```
θ₀ = acos(a · b)
slerp(a, b, t) = a·sin((1−t)θ₀)/sin(θ₀) + b·sin(tθ₀)/sin(θ₀)
```

#### `Quat.rotate(Vec3 v)`

Rotates vector `v` by this quaternion using the sandwich product:

```
v' = q × (0, v) × q*
```

Implemented efficiently as:

```dart
final u = Vec3(x, y, z);
final s = w;
return u * (2 * u.dot(v)) + v * (s*s - u.dot(u)) + u.cross(v) * (2*s);
```

#### `Quat.axisAngle` (decomposition)

Returns a named record `({Vec3 axis, double angle})`:

```dart
final (:axis, :angle) = myQuat.axisAngle;
```

---

## Transform3D

A complete immutable 3D transform combining position, rotation, and scale.

```dart
const Transform3D({
  required Vec3 position,
  required Quat rotation,
  required Vec3 scale,
})
```

### Named Constructors

```dart
Transform3D.identity                       // position=zero, rotation=identity, scale=one
Transform3D.translated(Vec3 offset)        // rotation=identity, scale=one
Transform3D.rotated(Quat q)                // position=zero, scale=one
Transform3D.scaled(double factor)          // position=zero, rotation=identity
```

### Converting to Matrix4

```dart
// Without perspective:
Matrix4 m = t.toMatrix4();

// With perspective (for Flutter Transform widget):
Matrix4 m = t.toMatrix4Perspective();         // default depth = 800
Matrix4 m = t.toMatrix4Perspective(1000);     // custom focal length
```

**Perspective formula:**

```dart
m.setEntry(3, 2, 1.0 / depth);   // adds perspective foreshortening
```

### Interpolation

```dart
Transform3D mid = a.lerp(b, 0.5);
```

- Position and scale use linear interpolation.
- Rotation uses **SLERP** via `Quat.slerp` — constant-speed, shortest arc.
- Short-circuit: `t ≤ 0` returns `this`; `t ≥ 1` returns `other`.

### Composition

```dart
Transform3D world = parent.compose(local);
```

Applies the local transform in the parent's coordinate space:

```
position = parent.position + parent.rotation.rotate(local.position × parent.scale)
rotation = parent.rotation × local.rotation
scale    = (parent.scale.x × local.scale.x, …)
```

### copyWith

```dart
final moved = t.copyWith(position: const Vec3(100, 0, 0));
```

### Equality & Hash

Implements structural `==` and `hashCode` via `Object.hash`.  Safe to use in `AnimatedSwitcher`, `ValueListenableBuilder`, etc.

---

## Transform3DTween

A `Tween<Transform3D>` that uses `lerp` (with SLERP for rotation).

```dart
final tween = Transform3DTween(
  begin: Transform3D.identity,
  end:   Transform3D(
    position: const Vec3(0, -80, 0),
    rotation: Quat.axisAngle(Vec3.up, math.pi / 2),
    scale:    Vec3.one,
  ),
);

// Drive with AnimationController
final anim = tween.animate(
  CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
);

// Evaluate
Transform3D current = anim.value;
```

---

## Matrix4Ext (Extension)

Extension methods on Flutter's `Matrix4`:

```dart
// Add perspective foreshortening
Matrix4 m = Matrix4.identity().withPerspective(800);  // depth = 800 px

// Build TRS matrix from Transform3D parts
Matrix4 m = Matrix4Ext.trs(position, rotation, scale);
```

---

## Coordinate System

`three_d_ui_builder` uses Flutter's native coordinate system:

| Axis | Positive direction | Notes |
|------|--------------------|-------|
| X | right | same as Flutter |
| Y | **down** | Flutter's Y-axis points down |
| Z | toward viewer | positive Z = closer to screen |

This means `Vec3.up` is `(0, −1, 0)` — negative Y — which matches Flutter's `Alignment.topCenter`.

When you call `toMatrix4Perspective()` the resulting matrix can be passed directly to Flutter's `Transform` widget without any coordinate conversion.
