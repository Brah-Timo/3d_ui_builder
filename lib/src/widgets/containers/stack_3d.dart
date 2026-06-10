import 'package:flutter/material.dart';

/// A [Stack]-like container that renders its children at distinct Z-depth
/// positions, creating genuine spatial separation.
///
/// Each child is wrapped in a [DepthEntry] which specifies:
/// - **depth**: Z-offset in logical pixels (positive = towards viewer).
/// - **offset**: optional 2-D position shift.
/// - **scale**: additional scale factor applied on top of the perspective scale.
///
/// The container applies a perspective transform and scales each child based
/// on its depth, so deeper layers appear smaller and more transparent.
///
/// ### Usage
/// ```dart
/// Stack3D(
///   perspectiveFocalLength: 600,
///   children: [
///     DepthEntry(depth: 0,   child: BackgroundLayer()),
///     DepthEntry(depth: 40,  child: MiddleLayer()),
///     DepthEntry(depth: 80,  child: ForegroundLayer()),
///   ],
/// )
/// ```
class Stack3D extends StatelessWidget {
  final List<DepthEntry> children;

  /// The virtual focal length in logical pixels.
  /// Larger values create a less dramatic perspective effect.
  final double perspectiveFocalLength;

  /// Alignment of each layer within the stack.
  final AlignmentGeometry alignment;

  const Stack3D({
    super.key,
    required this.children,
    this.perspectiveFocalLength = 600,
    this.alignment              = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    // Sort back-to-front (smaller depth first)
    final sorted = List<DepthEntry>.from(children)
      ..sort((a, b) => a.depth.compareTo(b.depth));

    return Stack(
      alignment: alignment,
      children: sorted.map((entry) {
        final scale   = perspectiveFocalLength /
            (perspectiveFocalLength + entry.depth);
        final opacity = (0.5 + 0.5 * scale).clamp(0.0, 1.0);

        return Transform.translate(
          offset: entry.offset ?? Offset.zero,
          child: Transform.scale(
            scale: scale * entry.scale,
            child: Opacity(
              opacity: opacity,
              child: entry.child,
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// A single layer in a [Stack3D].
class DepthEntry {
  /// Z-depth in logical pixels.  Higher = closer to viewer.
  final double depth;

  /// The widget at this depth.
  final Widget child;

  /// Optional 2-D offset within the stack.
  final Offset? offset;

  /// Additional scale factor (default 1.0).
  final double scale;

  const DepthEntry({
    required this.depth,
    required this.child,
    this.offset,
    this.scale = 1.0,
  });
}
