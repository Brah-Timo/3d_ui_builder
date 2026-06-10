import 'package:flutter/material.dart';

/// Renders text that appears to be physically extruded — i.e., it has real
/// depth like raised lettering on a metal plate.
///
/// The effect is achieved by painting multiple offset copies of the text
/// behind the main text layer, creating the illusion of a thick body.
///
/// For subtler effects use [depth] = 2–4.
/// For bold 3-D signage use [depth] = 8–16.
///
/// ### Usage
/// ```dart
/// ExtrudedText(
///   'HELLO',
///   style:     TextStyle(fontSize: 48, fontWeight: FontWeight.w900),
///   depth:     10,
///   faceColor: Colors.deepOrange,
///   sideColor: Colors.deepOrange.shade900,
/// )
/// ```
class ExtrudedText extends StatelessWidget {
  final String text;
  final TextStyle style;

  /// Number of extrusion layers (= visual depth in logical pixels).
  final int depth;

  /// Colour of the front face (the top surface of the text).
  final Color faceColor;

  /// Colour of the side (the extrusion body below the face).
  /// Defaults to a darkened shade of [faceColor].
  final Color? sideColor;

  /// Direction of the extrusion as a unit vector.
  /// Default is down-right, matching a standard top-left light source.
  final Offset extrusionDirection;

  /// Adds a specular shine line on the top edge.
  final bool showShine;

  const ExtrudedText(
    this.text, {
    super.key,
    this.style    = const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    this.depth    = 6,
    this.faceColor = const Color(0xFF5C6BC0),
    this.sideColor,
    this.extrusionDirection = const Offset(0.6, 0.8),
    this.showShine = true,
  });

  @override
  Widget build(BuildContext context) {
    final side = sideColor ??
        HSLColor.fromColor(faceColor)
            .withLightness(
              (HSLColor.fromColor(faceColor).lightness - 0.25).clamp(0, 1),
            )
            .toColor();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ── Extrusion layers (back to front) ─────────────────────────────────
        for (int i = depth; i >= 1; i--)
          Transform.translate(
            offset: extrusionDirection * i.toDouble(),
            child: Text(
              text,
              style: style.copyWith(
                color: side,
                shadows: null,
              ),
            ),
          ),

        // ── Face layer ────────────────────────────────────────────────────────
        Text(
          text,
          style: style.copyWith(
            color: faceColor,
            shadows: showShine
                ? [
                    Shadow(
                      color:  Colors.white.withAlpha(80),
                      offset: const Offset(-1, -1),
                      blurRadius: 0,
                    ),
                  ]
                : null,
          ),
        ),
      ],
    );
  }
}
