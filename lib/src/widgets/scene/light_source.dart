import 'package:flutter/material.dart';

import '../../core/math/vector3.dart';

/// Describes a light source in the 3-D scene.
///
/// [three_d_ui_builder] uses this to compute dynamic shadows and surface
/// highlights in the painter layer.  All shading is approximated using
/// custom painters — no GPU hardware lighting is used.
///
/// Three types are supported:
/// - [LightSource.directional] — a distant light with a constant direction.
/// - [LightSource.point]       — a positional point light with falloff.
/// - [LightSource.ambient]     — uniform omnidirectional fill light.
@immutable
class LightSource {
  final LightType type;

  /// World-space position (used by [LightType.point]).
  final Vec3 position;

  /// Light direction (used by [LightType.directional]; should be normalised).
  final Vec3 direction;

  /// Colour of the emitted light.
  final Color color;

  /// Intensity multiplier in [0, 1].
  final double intensity;

  /// Maximum reach of a [LightType.point] light in logical pixels.
  final double radius;

  const LightSource._({
    required this.type,
    required this.position,
    required this.direction,
    required this.color,
    required this.intensity,
    required this.radius,
  });

  // ─── Named constructors ────────────────────────────────────────────────────

  /// A directional light shining from [direction].
  const LightSource.directional({
    Vec3   direction = const Vec3(-0.4, -0.8, 0.4),
    Color  color     = Colors.white,
    double intensity = 0.9,
  }) : this._(
          type:      LightType.directional,
          position:  Vec3.zero,
          direction: direction,
          color:     color,
          intensity: intensity,
          radius:    double.infinity,
        );

  /// A point light at [position] with decay [radius].
  const LightSource.point({
    required Vec3 position,
    Color  color     = Colors.white,
    double intensity = 1.0,
    double radius    = 400,
  }) : this._(
          type:      LightType.point,
          position:  position,
          direction: Vec3.forward,
          color:     color,
          intensity: intensity,
          radius:    radius,
        );

  /// Uniform ambient light — no direction, no shadows.
  const LightSource.ambient({
    Color  color     = Colors.white,
    double intensity = 0.3,
  }) : this._(
          type:      LightType.ambient,
          position:  Vec3.zero,
          direction: Vec3.zero,
          color:     color,
          intensity: intensity,
          radius:    double.infinity,
        );

  // ─── Shading helpers ───────────────────────────────────────────────────────

  /// Computes the diffuse lighting factor [0, 1] for a surface at [point]
  /// with the given outward [normal].
  double diffuseFactor(Vec3 point, Vec3 normal) {
    switch (type) {
      case LightType.ambient:
        return intensity;

      case LightType.directional:
        final d = direction.normalized;
        return ((-d).dot(normal) * intensity).clamp(0.0, 1.0);

      case LightType.point:
        final toLight     = position - point;
        final dist        = toLight.length;
        if (dist > radius) return 0;
        final attenuation = 1 - (dist / radius).clamp(0.0, 1.0);
        final nDotL       = toLight.normalized.dot(normal);
        return (nDotL * intensity * attenuation).clamp(0.0, 1.0);
    }
  }
}

/// The type of a [LightSource].
enum LightType { directional, point, ambient }
