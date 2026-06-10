import 'package:flutter/material.dart';

/// Describes the physical surface properties of a 3-D widget.
///
/// These parameters drive the shadow, highlight, and edge colour calculations
/// throughout the library.
///
/// | Material          | Metalness | Roughness | Opacity |
/// |-------------------|-----------|-----------|---------|
/// | Matte paper       | 0.0       | 0.9       | 1.0     |
/// | Glossy plastic    | 0.1       | 0.2       | 1.0     |
/// | Metallic (steel)  | 0.9       | 0.1       | 1.0     |
/// | Frosted glass     | 0.0       | 0.05      | 0.7     |
/// | Rubber            | 0.0       | 0.95      | 1.0     |
@immutable
class Material3D {
  /// Base albedo colour.
  final Color color;

  /// Metal-ness in [0, 1].  `0` = dielectric (plastic), `1` = metallic.
  final double metalness;

  /// Surface roughness in [0, 1].  `0` = mirror-smooth, `1` = diffuse.
  final double roughness;

  /// Surface opacity in [0, 1].
  final double opacity;

  /// Whether the surface is frosted glass (backdrop blur when composited).
  final bool isFrosted;

  const Material3D({
    required this.color,
    this.metalness = 0.0,
    this.roughness = 0.5,
    this.opacity   = 1.0,
    this.isFrosted = false,
  });

  // ─── Named presets ─────────────────────────────────────────────────────────

  /// Flat matte finish — no highlight or reflection.
  factory Material3D.matte(Color color) => Material3D(
        color:     color,
        metalness: 0.0,
        roughness: 0.9,
      );

  /// Glossy plastic — strong highlight, low roughness.
  factory Material3D.glossyPlastic(Color color) => Material3D(
        color:     color,
        metalness: 0.1,
        roughness: 0.2,
      );

  /// Polished metal — highly reflective.
  factory Material3D.metallic(Color color) => Material3D(
        color:     color,
        metalness: 0.9,
        roughness: 0.1,
      );

  /// Frosted glass — semi-transparent with negligible roughness.
  factory Material3D.frostedGlass({Color tint = Colors.white}) => Material3D(
        color:     tint,
        metalness: 0.0,
        roughness: 0.05,
        opacity:   0.72,
        isFrosted: true,
      );

  /// Soft rubber — very high roughness, no shine.
  factory Material3D.rubber(Color color) => Material3D(
        color:     color,
        metalness: 0.0,
        roughness: 0.95,
      );

  // ─── Derived colours ───────────────────────────────────────────────────────

  /// Returns the highlight colour derived from [color] and [metalness].
  Color get highlightColor {
    if (metalness > 0.5) {
      // For metals, highlight takes on the material colour
      return Color.lerp(Colors.white70, color, metalness * 0.6) ?? Colors.white;
    }
    return Colors.white.withAlpha((0.4 + (1 - roughness) * 0.6 * 255).round());
  }

  /// Returns the shadow/edge colour — darkened version of [color].
  Color get shadowColor {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness * (0.4 + roughness * 0.2)).clamp(0, 1))
        .toColor();
  }

  // ─── copyWith ──────────────────────────────────────────────────────────────

  Material3D copyWith({
    Color?  color,
    double? metalness,
    double? roughness,
    double? opacity,
    bool?   isFrosted,
  }) =>
      Material3D(
        color:     color     ?? this.color,
        metalness: metalness ?? this.metalness,
        roughness: roughness ?? this.roughness,
        opacity:   opacity   ?? this.opacity,
        isFrosted: isFrosted ?? this.isFrosted,
      );

  @override
  bool operator ==(Object other) =>
      other is Material3D &&
      color     == other.color     &&
      metalness == other.metalness &&
      roughness == other.roughness &&
      opacity   == other.opacity   &&
      isFrosted == other.isFrosted;

  @override
  int get hashCode =>
      Object.hash(color, metalness, roughness, opacity, isFrosted);
}
