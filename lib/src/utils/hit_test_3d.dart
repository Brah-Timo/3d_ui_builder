import 'package:flutter/widgets.dart';

import '../core/foundation/three_d_object.dart';
import '../utils/perspective_utils.dart';

/// Provides hit-testing utilities for 3-D objects projected onto a 2-D screen.
///
/// Because all rendering in [three_d_ui_builder] uses Flutter's normal widget
/// tree, most pointer events are handled by the widgets themselves.  These
/// helpers are only needed when you have a custom [SceneRenderer] and need to
/// manually determine which [ThreeDObject] was touched.
abstract final class HitTest3D {
  HitTest3D._();

  // ─── Point-in-circle ───────────────────────────────────────────────────────

  /// Returns the first [ThreeDObject] whose projected screen position is
  /// within [radius] logical pixels of [screenPoint], or `null` if none.
  ///
  /// Searches front-to-back (closest Z first) so the topmost object wins.
  static ThreeDObject? hitTest({
    required List<ThreeDObject> objects,
    required Offset screenPoint,
    required Size   screenSize,
    double   radius      = 40,
    double   focalLength = 800,
  }) {
    final centre = Offset(screenSize.width / 2, screenSize.height / 2);

    // Front-to-back
    final sorted = objects.toList()
      ..sort((a, b) => b.depth.compareTo(a.depth));

    for (final obj in sorted) {
      if (!obj.visible || !obj.interactive) continue;
      final screenPos = PerspectiveUtils.project(
        obj.transform.position,
        screenCentre: centre,
        focalLength:  focalLength,
      );
      final dist = (screenPos - screenPoint).distance;
      if (dist <= radius) return obj;
    }
    return null;
  }

  // ─── AABB test ─────────────────────────────────────────────────────────────

  /// Returns `true` if [screenPoint] lies within the bounding box [rect]
  /// after applying the projected position of [object].
  static bool hitTestRect({
    required ThreeDObject object,
    required Offset       screenPoint,
    required Size         screenSize,
    required Size         objectSize,
    double focalLength = 800,
  }) {
    final centre = Offset(screenSize.width / 2, screenSize.height / 2);
    final projected = PerspectiveUtils.project(
      object.transform.position,
      screenCentre: centre,
      focalLength:  focalLength,
    );

    final scale = PerspectiveUtils.depthScale(
      object.transform.position.z,
      focalLength: focalLength,
    );

    final halfW = objectSize.width  / 2 * scale;
    final halfH = objectSize.height / 2 * scale;

    return screenPoint.dx >= projected.dx - halfW &&
           screenPoint.dx <= projected.dx + halfW &&
           screenPoint.dy >= projected.dy - halfH &&
           screenPoint.dy <= projected.dy + halfH;
  }
}
