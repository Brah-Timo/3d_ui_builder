import 'package:flutter/material.dart';

import 'depth_shadow_style.dart';
import 'material_3d.dart';
import '../core/math/vector3.dart';

/// An [InheritedWidget] that propagates [ThreeDThemeData] down the widget tree.
///
/// Wrap your application root (or any subtree) with [ThreeDTheme] to configure
/// the default appearance of all [three_d_ui_builder] widgets below it.
///
/// ```dart
/// ThreeDTheme(
///   data: ThreeDThemeData(
///     defaultDepth:   7.0,
///     defaultMaterial: Material3D.glossyPlastic(Colors.indigo),
///     shadowStyle:    DepthShadowStyle.soft,
///     enableLighting: true,
///     lightPosition:  Vec3(-200, -300, 500),
///   ),
///   child: MaterialApp(...),
/// )
/// ```
class ThreeDTheme extends InheritedWidget {
  final ThreeDThemeData data;

  const ThreeDTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// Returns the nearest [ThreeDThemeData], falling back to defaults.
  static ThreeDThemeData of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<ThreeDTheme>()
            ?.data ??
        ThreeDThemeData.defaults();
  }

  @override
  bool updateShouldNotify(ThreeDTheme old) => old.data != data;
}

/// The immutable data object carried by [ThreeDTheme].
@immutable
class ThreeDThemeData {
  /// Default extrusion depth for buttons and panels (logical pixels).
  final double defaultDepth;

  /// Default [Material3D] applied to all surfaces.
  final Material3D defaultMaterial;

  /// Default shadow style.
  final DepthShadowStyle shadowStyle;

  /// Whether widgets compute dynamic lighting effects.
  final bool enableLighting;

  /// World-space position of the primary light source.
  final Vec3 lightPosition;

  /// Default perspective coefficient.
  final double perspective;

  const ThreeDThemeData({
    required this.defaultDepth,
    required this.defaultMaterial,
    required this.shadowStyle,
    required this.enableLighting,
    required this.lightPosition,
    required this.perspective,
  });

  // ─── Defaults ──────────────────────────────────────────────────────────────

  factory ThreeDThemeData.defaults() => ThreeDThemeData(
        defaultDepth:    6.0,
        defaultMaterial: Material3D.matte(Colors.white),
        shadowStyle:     DepthShadowStyle.soft,
        enableLighting:  true,
        lightPosition:   const Vec3(-150, -250, 400),
        perspective:     0.001,
      );

  // ─── Preset themes ─────────────────────────────────────────────────────────

  /// Dark glossy theme inspired by sci-fi HUDs.
  factory ThreeDThemeData.cyberpunk() => ThreeDThemeData(
        defaultDepth:    8.0,
        defaultMaterial: Material3D.glossyPlastic(const Color(0xFF00FFCC)),
        shadowStyle:     DepthShadowStyle.colored,
        enableLighting:  true,
        lightPosition:   const Vec3(200, -400, 300),
        perspective:     0.0012,
      );

  /// Clean white neumorphic style.
  factory ThreeDThemeData.neumorphic() => ThreeDThemeData(
        defaultDepth:    4.0,
        defaultMaterial: Material3D.matte(const Color(0xFFE0E5EC)),
        shadowStyle:     DepthShadowStyle.soft,
        enableLighting:  false,
        lightPosition:   Vec3.zero,
        perspective:     0.0008,
      );

  // ─── copyWith ──────────────────────────────────────────────────────────────

  ThreeDThemeData copyWith({
    double?          defaultDepth,
    Material3D?      defaultMaterial,
    DepthShadowStyle? shadowStyle,
    bool?            enableLighting,
    Vec3?            lightPosition,
    double?          perspective,
  }) =>
      ThreeDThemeData(
        defaultDepth:    defaultDepth    ?? this.defaultDepth,
        defaultMaterial: defaultMaterial ?? this.defaultMaterial,
        shadowStyle:     shadowStyle     ?? this.shadowStyle,
        enableLighting:  enableLighting  ?? this.enableLighting,
        lightPosition:   lightPosition   ?? this.lightPosition,
        perspective:     perspective     ?? this.perspective,
      );

  @override
  bool operator ==(Object other) =>
      other is ThreeDThemeData &&
      defaultDepth    == other.defaultDepth    &&
      defaultMaterial == other.defaultMaterial &&
      shadowStyle     == other.shadowStyle     &&
      enableLighting  == other.enableLighting  &&
      lightPosition   == other.lightPosition   &&
      perspective     == other.perspective;

  @override
  int get hashCode => Object.hash(
        defaultDepth, defaultMaterial, shadowStyle,
        enableLighting, lightPosition, perspective,
      );
}
