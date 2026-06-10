import 'package:flutter/foundation.dart';

import '../math/transform3d.dart';
import '../math/vector3.dart';

/// The base data class for every object living inside a [ThreeDScene].
///
/// A [ThreeDObject] is a pure data record — it holds the spatial transform
/// and display metadata for one node in the scene graph.  It does not extend
/// [Widget]; instead, the companion [ThreeDSceneWidget] reads the scene and
/// renders each object through its registered builder callback.
///
/// All properties are immutable.  To "move" an object, call [copyWith] and
/// replace the old entry in the scene.
@immutable
class ThreeDObject {
  /// Unique identifier used to reference this object in the scene.
  final String id;

  /// The world-space transform of this object.
  final Transform3D transform;

  /// Optional tag used for hit-testing and collision groups.
  final String? tag;

  /// Controls draw order within the same Z-bucket.
  /// Objects with higher priority are rendered above lower ones.
  final int renderPriority;

  /// Whether this object should be considered for pointer / touch hit-tests.
  final bool interactive;

  /// Whether this object is currently visible.
  final bool visible;

  const ThreeDObject({
    required this.id,
    required this.transform,
    this.tag,
    this.renderPriority = 0,
    this.interactive    = true,
    this.visible        = true,
  });

  // ─── Helpers ───────────────────────────────────────────────────────────────

  /// Returns the world-space position.
  Vec3 get position => transform.position;

  /// Returns the depth value (Z component), used by [DepthSorter].
  double get depth => transform.position.z;

  ThreeDObject copyWith({
    String?      id,
    Transform3D? transform,
    String?      tag,
    int?         renderPriority,
    bool?        interactive,
    bool?        visible,
  }) =>
      ThreeDObject(
        id:             id             ?? this.id,
        transform:      transform      ?? this.transform,
        tag:            tag            ?? this.tag,
        renderPriority: renderPriority ?? this.renderPriority,
        interactive:    interactive    ?? this.interactive,
        visible:        visible        ?? this.visible,
      );

  @override
  bool operator ==(Object other) =>
      other is ThreeDObject &&
      id == other.id &&
      transform == other.transform;

  @override
  int get hashCode => Object.hash(id, transform);

  @override
  String toString() =>
      'ThreeDObject(id: $id, pos: ${transform.position}, visible: $visible)';
}
