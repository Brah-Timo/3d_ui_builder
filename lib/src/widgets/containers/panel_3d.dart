import 'package:flutter/material.dart';

/// A flat panel with a convincing 3-D depth illusion created by:
/// - A perspective-tilted [Transform] applied to the panel.
/// - A layered bottom/right slab to simulate a thick edge.
/// - A dynamic shadow that shifts based on the tilt angle.
///
/// [Panel3D] is ideal for floating info cards, HUD elements, and
/// dashboard tiles.
///
/// ### Usage
/// ```dart
/// Panel3D(
///   width:  320,
///   height: 180,
///   tiltX:  5,   // degrees
///   tiltY: -8,   // degrees
///   child: MyContent(),
/// )
/// ```
class Panel3D extends StatelessWidget {
  final Widget child;

  final double? width;
  final double? height;

  /// Tilt around the X-axis in degrees (positive = top tilts away).
  final double tiltX;

  /// Tilt around the Y-axis in degrees (positive = right side tilts away).
  final double tiltY;

  /// Thickness of the edge slab in logical pixels.
  final double edgeDepth;

  /// Panel corner radius.
  final double borderRadius;

  /// The main (face) colour.  Defaults to [ThemeData.cardColor].
  final Color? color;

  /// Edge slab colour.  Defaults to a darker shade of [color].
  final Color? edgeColor;

  /// Perspective coefficient.
  final double perspective;

  const Panel3D({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.tiltX        = 0,
    this.tiltY        = 0,
    this.edgeDepth    = 8,
    this.borderRadius = 16,
    this.color,
    this.edgeColor,
    this.perspective  = 0.001,
  });

  @override
  Widget build(BuildContext context) {
    final theme     = Theme.of(context);
    final face      = color     ?? theme.cardColor;
    final edge      = edgeColor ?? _darken(face, 0.18);
    final radX      = tiltX * 3.14159 / 180;
    final radY      = tiltY * 3.14159 / 180;

    final tiltMatrix = Matrix4.identity()
      ..setEntry(3, 2, perspective)
      ..rotateX(radX)
      ..rotateY(radY);

    // Shadow offset follows the tilt
    final shadowDx = tiltY.clamp(-30.0, 30.0) * 0.3;
    final shadowDy = tiltX.clamp(-30.0, 30.0) * 0.3 + edgeDepth;

    return Transform(
      alignment: Alignment.center,
      transform: tiltMatrix,
      child: CustomPaint(
        painter: _Panel3DPainter(
          faceColor:    face,
          edgeColor:    edge,
          depth:        edgeDepth,
          radius:       borderRadius,
          shadowDx:     shadowDx,
          shadowDy:     shadowDy,
        ),
        child: SizedBox(
          width:  width,
          height: height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _Panel3DPainter extends CustomPainter {
  final Color faceColor;
  final Color edgeColor;
  final double depth;
  final double radius;
  final double shadowDx;
  final double shadowDy;

  const _Panel3DPainter({
    required this.faceColor,
    required this.edgeColor,
    required this.depth,
    required this.radius,
    required this.shadowDx,
    required this.shadowDy,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final br = Radius.circular(radius);

    // Shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(shadowDx, shadowDy, size.width, size.height),
        br,
      ),
      Paint()
        ..color = Colors.black.withAlpha(50)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
    );

    // Edge slab
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, depth, size.width, size.height),
        br,
      ),
      Paint()..color = edgeColor,
    );

    // Face
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        br,
      ),
      Paint()..color = faceColor,
    );
  }

  @override
  bool shouldRepaint(_Panel3DPainter old) =>
      old.depth      != depth     ||
      old.faceColor  != faceColor ||
      old.shadowDx   != shadowDx;
}

Color _darken(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
}
