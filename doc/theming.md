# Theming

`three_d_ui_builder` uses a single `InheritedWidget` — `ThreeDTheme` — to propagate visual configuration down the widget tree. Every widget in the library reads from this theme automatically and falls back to sensible defaults if no theme is found.

---

## ThreeDTheme

```dart
ThreeDTheme({
  required ThreeDThemeData data,
  required Widget child,
})
```

Place `ThreeDTheme` anywhere in your widget tree.  It only affects widgets in its subtree.

**Reading the theme from a widget:**

```dart
final theme = ThreeDTheme.of(context);
final depth = theme.defaultDepth;
```

---

## ThreeDThemeData

The immutable data object carried by `ThreeDTheme`.

```dart
ThreeDThemeData({
  required double          defaultDepth,
  required Material3D      defaultMaterial,
  required DepthShadowStyle shadowStyle,
  required bool             enableLighting,
  required Vec3             lightPosition,
  required double           perspective,
})
```

### Fields

| Field | Type | Description |
|-------|------|-------------|
| `defaultDepth` | `double` | Default Z-extrusion depth for buttons and panels (logical pixels) |
| `defaultMaterial` | `Material3D` | Default surface material for all 3D widgets |
| `shadowStyle` | `DepthShadowStyle` | How drop shadows are rendered |
| `enableLighting` | `bool` | Whether widgets compute dynamic lighting effects |
| `lightPosition` | `Vec3` | World-space position of the primary light source |
| `perspective` | `double` | Perspective coefficient (≈ `1 / focalLength`) |

### Built-in Presets

#### `ThreeDThemeData.defaults()`

Clean, neutral starting point.

```dart
ThreeDThemeData(
  defaultDepth:    6.0,
  defaultMaterial: Material3D.matte(Colors.white),
  shadowStyle:     DepthShadowStyle.soft,
  enableLighting:  true,
  lightPosition:   Vec3(-150, -250, 400),
  perspective:     0.001,
)
```

#### `ThreeDThemeData.cyberpunk()`

Dark sci-fi HUD aesthetic: deep extrusion, neon highlights, high contrast.

```dart
ThreeDThemeData(
  defaultDepth:    8.0,
  defaultMaterial: Material3D.glossyPlastic(Color(0xFF00FFCC)),
  shadowStyle:     DepthShadowStyle.colored,
  enableLighting:  true,
  lightPosition:   Vec3(200, -400, 300),
  perspective:     0.0012,
)
```

#### `ThreeDThemeData.neumorphic()`

Soft-extruded, light-grey embossed style.

```dart
ThreeDThemeData(
  defaultDepth:    4.0,
  defaultMaterial: Material3D.matte(Color(0xFFE0E5EC)),
  shadowStyle:     DepthShadowStyle.soft,
  enableLighting:  false,
  lightPosition:   Vec3.zero,
  perspective:     0.0008,
)
```

### copyWith

```dart
final darkTheme = ThreeDThemeData.defaults().copyWith(
  defaultDepth: 10,
  shadowStyle: DepthShadowStyle.sharp,
);
```

---

## Material3D

Describes the physical surface properties of a 3D widget.

```dart
const Material3D({
  required Color color,
  double metalness = 0.0,    // 0 = dielectric, 1 = metallic
  double roughness = 0.5,    // 0 = mirror, 1 = diffuse
  double opacity   = 1.0,    // 0 = transparent, 1 = opaque
  bool   isFrosted = false,  // frosted glass (backdrop blur)
})
```

### Named Presets

#### `Material3D.matte(Color color)`

Flat diffuse surface — no specular highlight. Good for cards, panels, backgrounds.

```
metalness: 0.0  roughness: 0.9  opacity: 1.0
```

#### `Material3D.glossyPlastic(Color color)`

Shiny plastic with a bright specular streak. Good for buttons and badges.

```
metalness: 0.1  roughness: 0.2  opacity: 1.0
```

#### `Material3D.metallic(Color color)`

Mirror-like metal. The highlight colour takes on a tint of the base colour. Good for premium CTAs.

```
metalness: 0.9  roughness: 0.1  opacity: 1.0
```

#### `Material3D.frostedGlass({Color tint})`

Semi-transparent frosted glass. When composited over content, `BackdropFilter` can be applied externally for the blur effect.

```
metalness: 0.0  roughness: 0.05  opacity: 0.72  isFrosted: true
```

#### `Material3D.rubber(Color color)`

Matte, very rough surface. Good for dark UI handles and grips.

```
metalness: 0.0  roughness: 0.95  opacity: 1.0
```

### Derived Colours

The material computes helper colours used internally by painters:

```dart
Color get highlightColor   // bright streak on lit edges
Color get shadowColor      // darkened colour for unlit/shadow edges
```

For metals, `highlightColor` is tinted toward the `color`.  
For dielectrics, `highlightColor` is white at intensity `(1 − roughness)`.

---

## DepthShadowStyle

Controls how drop shadows appear under 3D widgets.

```dart
enum DepthShadowStyle {
  soft,      // Gaussian-blurred elliptical shadow (default)
  sharp,     // Hard-edge shadow — good for cyberpunk / geometric styles
  colored,   // Shadow is tinted by the light source colour
}
```

### Visual Examples

| Style | Sigma | Appearance |
|-------|-------|------------|
| `soft` | `depth * 1.5` | Diffused, natural |
| `sharp` | `1.0` | Crisp, geometric |
| `colored` | `depth * 1.2` | Neon glow effect |

---

## Theme Scope: Partial Override

You can wrap only a section of your UI in a different theme:

```dart
// App uses defaults
ThreeDTheme(
  data: ThreeDThemeData.defaults(),
  child: Column(
    children: [
      NormalSection(),      // gets defaults

      // Only this section uses cyberpunk style
      ThreeDTheme(
        data: ThreeDThemeData.cyberpunk(),
        child: const HeroSection(),
      ),

      NormalSection(),      // still gets defaults
    ],
  ),
)
```

---

## Per-Widget Override

Every widget that reads the theme accepts its own explicit parameters. Explicit parameters always take priority over the theme:

```dart
// Theme says defaultDepth = 6, but this button uses depth = 14
ThreeDButton(
  depth: 14,          // ← overrides theme
  label: const Text('VIP'),
  onPressed: () {},
)
```

---

## Connecting to Flutter's ThemeData

You can derive a `ThreeDThemeData` from Flutter's `ThemeData` to keep both themes in sync:

```dart
Widget build(BuildContext context) {
  final flutterTheme = Theme.of(context);

  return ThreeDTheme(
    data: ThreeDThemeData.defaults().copyWith(
      defaultMaterial: Material3D.glossyPlastic(flutterTheme.colorScheme.primary),
      lightPosition: flutterTheme.brightness == Brightness.dark
          ? const Vec3(200, -300, 400)
          : const Vec3(-150, -250, 500),
    ),
    child: child,
  );
}
```
