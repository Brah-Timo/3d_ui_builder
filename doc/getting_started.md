# Getting Started with three_d_ui_builder

This guide walks you from zero to your first working 3D widget in under five minutes.

---

## 1. Requirements

| Tool | Minimum version |
|------|----------------|
| Dart SDK | 3.3.0 |
| Flutter SDK | 3.24.0 |
| Xcode (iOS/macOS) | 15.0 |
| Android Studio / Gradle | AGP 8.1 |

The package works on all Flutter platforms.  For the best visual quality on Desktop (macOS, Windows, Linux), enable Impeller:

```sh
flutter run --enable-impeller
```

---

## 2. Add the Dependency

In your project's `pubspec.yaml`:

```yaml
dependencies:
  three_d_ui_builder: ^0.1.0
```

Then fetch:

```sh
flutter pub get
```

---

## 3. The Single Import

The package exposes one barrel file. Add it to any Dart file:

```dart
import 'package:three_d_ui_builder/three_d_ui_builder.dart';
```

This gives you access to every widget, math type, animation class, and theme token.

---

## 4. Wrap Your App with ThreeDTheme

`ThreeDTheme` is an `InheritedWidget` that propagates visual defaults (depth, material, perspective) to all `three_d_ui_builder` widgets in its subtree.

```dart
import 'package:flutter/material.dart';
import 'package:three_d_ui_builder/three_d_ui_builder.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ThreeDTheme(
      data: ThreeDThemeData.defaults(),  // ← sensible out-of-the-box defaults
      child: MaterialApp(
        title: 'My 3D App',
        home: const MyHomePage(),
      ),
    );
  }
}
```

> **Tip:** `ThreeDTheme` is optional.  Every widget falls back to `ThreeDThemeData.defaults()` if no theme is found in the tree.

---

## 5. Your First 3D Button

```dart
class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ThreeDButton(
          label: const Text(
            'Press Me',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          faceColor: Colors.deepPurple,
          depth: 8.0,
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pressed!')),
          ),
        ),
      ),
    );
  }
}
```

Run the app, tap the button, and notice how it physically depresses into the screen then springs back.

---

## 6. Add a Flip Card

```dart
FlipCard3D(
  front: Container(
    width: 280,
    height: 180,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.purple.shade800, Colors.blue.shade900],
      ),
      borderRadius: BorderRadius.circular(20),
    ),
    child: const Center(
      child: Text('Tap to flip →', style: TextStyle(color: Colors.white)),
    ),
  ),
  back: Container(
    width: 280,
    height: 180,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.teal.shade800, Colors.green.shade900],
      ),
      borderRadius: BorderRadius.circular(20),
    ),
    child: const Center(
      child: Text('← Tap to flip back', style: TextStyle(color: Colors.white)),
    ),
  ),
)
```

---

## 7. Add a Circular 3D List

```dart
SizedBox(
  height: 360,
  child: CircularList3D(
    itemCount: 8,
    radius: 180,
    tiltAngle: 0.35,
    autoRotate: true,
    rotationSpeed: 0.2,
    itemBuilder: (ctx, index) => Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: Colors.primaries[index * 3 % Colors.primaries.length],
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          '${index + 1}',
          style: const TextStyle(color: Colors.white, fontSize: 22),
        ),
      ),
    ),
  ),
)
```

---

## 8. Complete Minimal Example

Below is a self-contained file you can drop into a new Flutter project:

```dart
import 'package:flutter/material.dart';
import 'package:three_d_ui_builder/three_d_ui_builder.dart';

void main() => runApp(const DemoApp());

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ThreeDTheme(
      data: ThreeDThemeData.defaults(),
      child: const MaterialApp(
        title: '3D UI Starter',
        debugShowCheckedModeBanner: false,
        home: StarterScreen(),
      ),
    );
  }
}

class StarterScreen extends StatelessWidget {
  const StarterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ThreeDButton(
              label: const Text(
                'Hello 3D',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              faceColor: Colors.indigo,
              depth: 8,
              onPressed: () {},
            ),
            const SizedBox(height: 40),
            FlipCard3D(
              front: _face('Front', Colors.purple.shade800),
              back:  _face('Back',  Colors.teal.shade800),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _face(String label, Color color) => Container(
        width: 260,
        height: 160,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 24),
          ),
        ),
      );
}
```

---

## Next Steps

- Read the [Widget Reference](widgets.md) for the full API of every widget.
- Explore [Theming](theming.md) to configure the global 3D look.
- Study [Math Primitives](math.md) to build custom 3D widgets.
- Check [Performance](performance.md) to keep frame rates above 60 fps.
