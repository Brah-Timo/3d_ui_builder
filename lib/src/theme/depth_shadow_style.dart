import 'package:flutter/material.dart';

/// Describes how depth shadows are rendered on 3-D widgets.
///
/// Three visual styles are available:
/// - [DepthShadowStyle.soft]  — large blur, low opacity.
/// - [DepthShadowStyle.crisp] — small blur, high opacity.
/// - [DepthShadowStyle.colored] — tinted shadow that matches the widget colour.
@immutable
class DepthShadowStyle {
  /// Base shadow colour.
  final Color color;

  /// Blur sigma for the shadow.
  final double blurRadius;

  /// Offset of the shadow from the widget.
  final Offset offset;

  /// Whether to tint the shadow with the widget's face colour.
  final bool isColored;

  /// Tint factor when [isColored] is true.
  final double tintStrength;

  const DepthShadowStyle({
    required this.color,
    required this.blurRadius,
    required this.offset,
    this.isColored     = false,
    this.tintStrength  = 0.3,
  });

  // ─── Named presets ─────────────────────────────────────────────────────────

  /// A soft, diffuse shadow.
  static const DepthShadowStyle soft = DepthShadowStyle(
    color:      Color(0x44000000),
    blurRadius: 24,
    offset:     Offset(0, 8),
  );

  /// A crisp, hard-edged shadow.
  static const DepthShadowStyle crisp = DepthShadowStyle(
    color:      Color(0x88000000),
    blurRadius: 4,
    offset:     Offset(4, 4),
  );

  /// A coloured ambient occlusion shadow.
  static const DepthShadowStyle colored = DepthShadowStyle(
    color:      Color(0x55000080),
    blurRadius: 18,
    offset:     Offset(0, 6),
    isColored:  true,
    tintStrength: 0.4,
  );

  /// No shadow.
  static const DepthShadowStyle none = DepthShadowStyle(
    color:      Color(0x00000000),
    blurRadius: 0,
    offset:     Offset.zero,
  );

  // ─── Helpers ───────────────────────────────────────────────────────────────

  /// Returns the effective shadow colour, optionally blended with [faceColor].
  Color effectiveColor(Color faceColor) {
    if (!isColored) return color;
    return Color.lerp(color, faceColor.withAlpha(color.alpha), tintStrength)!;
  }

  /// Converts to a Flutter [BoxShadow].
  BoxShadow toBoxShadow({Color? faceColor}) => BoxShadow(
        color:      effectiveColor(faceColor ?? Colors.black),
        blurRadius: blurRadius,
        offset:     offset,
      );

  DepthShadowStyle copyWith({
    Color?  color,
    double? blurRadius,
    Offset? offset,
    bool?   isColored,
    double? tintStrength,
  }) =>
      DepthShadowStyle(
        color:        color        ?? this.color,
        blurRadius:   blurRadius   ?? this.blurRadius,
        offset:       offset       ?? this.offset,
        isColored:    isColored    ?? this.isColored,
        tintStrength: tintStrength ?? this.tintStrength,
      );

  @override
  bool operator ==(Object other) =>
      other is DepthShadowStyle &&
      color      == other.color      &&
      blurRadius == other.blurRadius &&
      offset     == other.offset;

  @override
  int get hashCode => Object.hash(color, blurRadius, offset);
}
