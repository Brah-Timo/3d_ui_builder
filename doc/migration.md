# Migration Guide

This guide helps you move from deprecated or incompatible 3D Flutter packages to `three_d_ui_builder`.

---

## Migrating from flutter_3d

`flutter_3d` (pub.dev package, last updated 2021) is fully unmaintained and incompatible with Flutter 3.x.  Its API was low-level: you had to manage `Object3D`, `Mesh`, and vertex data manually.

### Comparison

| Task | flutter_3d | three_d_ui_builder |
|------|------------|-------------------|
| Rotating object | `object3d.rotateY(angle)` in a game loop | `FlipCard3D` or `Drag3DRecognizer` |
| 3D button | Custom mesh + manual input handling | `ThreeDButton(depth: 8, onPressed: …)` |
| Flip animation | Manual interpolation loop | `FlipCard3D(flipDuration: …)` |
| Theming | Global config singleton | `ThreeDTheme(data: …, child: …)` |

### Migration Steps

1. Remove `flutter_3d` from `pubspec.yaml`.
2. Add `three_d_ui_builder: ^0.1.0`.
3. Replace `flutter_3d` imports with `package:three_d_ui_builder/three_d_ui_builder.dart`.
4. Replace `Object3D` / `Mesh` usage with the appropriate widget (`FlipCard3D`, `CubeContainer`, etc.).
5. Replace custom rotation loops with `Drag3DRecognizer` or `RotationAnimation`.

There is no automatic migration tool — the APIs are conceptually different enough that a case-by-case rewrite is required.

---

## Using three_d_ui_builder alongside flutter_scene

`flutter_scene` is a lower-level 3D rendering engine for Flutter, designed for game-quality graphics with glTF model loading and PBR lighting.  It operates at a fundamentally different level than `three_d_ui_builder`.

**You can use both packages in the same app** — they don't conflict.  A common architecture is:

```dart
// Use flutter_scene for the game world / 3D scene background
SceneWidget(
  scene: myFlutterScene,
  child: Stack(
    children: [
      // Use three_d_ui_builder for the HUD / UI layer on top
      Positioned(
        bottom: 20, left: 20,
        child: ThreeDButton(
          label: const Text('Menu'),
          onPressed: openMenu,
        ),
      ),
      Positioned(
        top: 20, right: 20,
        child: CircularList3D(
          itemCount: powerUps.length,
          itemBuilder: (ctx, i) => PowerUpIcon(powerUps[i]),
          radius: 80,
        ),
      ),
    ],
  ),
)
```

### Differences

| Aspect | flutter_scene | three_d_ui_builder |
|--------|--------------|-------------------|
| Level | GPU / scene graph | Flutter widget tree |
| Models | glTF 2.0, Mesh primitives | Flutter widgets on surfaces |
| Shaders | Custom GLSL / WGSL | Flutter's Skia/Impeller default |
| Lighting | PBR (physically based) | Approximate 2.5D |
| Platform requirement | Impeller (Flutter master/preview) | Any Flutter ≥ 3.24 stable |
| Use case | 3D worlds, models, simulations | UI elements: buttons, cards, menus |

---

## Migrating from zflutter

`zflutter` renders simple 3D shapes (boxes, planes, spheres) using `CustomPainter`.  It doesn't support interactive widgets as surfaces.

### Comparison

| Feature | zflutter | three_d_ui_builder |
|---------|---------|-------------------|
| Widget on surface | ❌ Not supported | ✅ Any Flutter widget |
| Physics animation | ❌ Manual | ✅ `Spring3D` |
| Gesture system | ❌ Manual | ✅ `Drag3DRecognizer` |
| Theme system | ❌ None | ✅ `ThreeDTheme` |
| Active maintenance | ⚠️ Irregular | ✅ Active |

### Migration Steps

1. Remove `zflutter` from `pubspec.yaml`.
2. Replace `ZWidget` with the appropriate `three_d_ui_builder` widget:
   - `ZRect` + `ZPositioned` → `Panel3D` or `DepthCard`
   - `ZBox` → `CubeContainer`
   - `ZGroup` → `Stack3D`
3. Replace `ZIlluminator` with `ThreeDTheme(data: ThreeDThemeData(enableLighting: true, lightPosition: …))`.

---

## Version History of three_d_ui_builder

| Version | Breaking changes |
|---------|-----------------|
| 0.1.0 | Initial release — no migration needed |

Future breaking changes (if any) will be documented here with step-by-step migration instructions before the new version is published.
