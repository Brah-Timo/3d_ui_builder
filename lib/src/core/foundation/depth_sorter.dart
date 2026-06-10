import 'three_d_object.dart';

/// Sorts a list of [ThreeDObject]s by depth (Z-axis) so that objects farther
/// from the viewer are drawn first (painter's algorithm).
///
/// Objects with equal depth are secondarily sorted by [ThreeDObject.renderPriority]
/// — higher priority renders on top.
///
/// This is a pure utility class with no state.
abstract final class DepthSorter {
  DepthSorter._();

  /// Returns a new list with objects sorted back-to-front (furthest first).
  ///
  /// This is the standard order for correct alpha blending.
  static List<ThreeDObject> backToFront(List<ThreeDObject> objects) {
    final sorted = List<ThreeDObject>.from(objects);
    sorted.sort(_compareBackToFront);
    return sorted;
  }

  /// Returns a new list with objects sorted front-to-back (closest first).
  ///
  /// Useful for early-Z culling in opaque passes.
  static List<ThreeDObject> frontToBack(List<ThreeDObject> objects) {
    final sorted = List<ThreeDObject>.from(objects);
    sorted.sort(_compareFrontToBack);
    return sorted;
  }

  // ─── Comparators ──────────────────────────────────────────────────────────

  static int _compareBackToFront(ThreeDObject a, ThreeDObject b) {
    // Smaller Z = further from viewer; draw first
    final zCompare = a.depth.compareTo(b.depth);
    if (zCompare != 0) return zCompare;
    // Equal depth: lower priority first (will be covered by higher priority)
    return a.renderPriority.compareTo(b.renderPriority);
  }

  static int _compareFrontToBack(ThreeDObject a, ThreeDObject b) =>
      -_compareBackToFront(a, b);
}
