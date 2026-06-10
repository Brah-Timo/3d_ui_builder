import 'package:flutter/foundation.dart';

import 'depth_sorter.dart';
import 'three_d_object.dart';
import '../math/transform3d.dart';

/// A [ChangeNotifier] that manages a collection of [ThreeDObject]s.
///
/// [ThreeDScene] acts as the model layer for the 3-D scene graph.
/// The companion [ThreeDSceneWidget] listens to this notifier and rebuilds
/// whenever the scene changes.
///
/// ### Usage
/// ```dart
/// final scene = ThreeDScene();
///
/// // Add an object
/// scene.add(ThreeDObject(id: 'card', transform: Transform3D.identity));
///
/// // Move it
/// scene.updateTransform('card',
///   Transform3D(position: Vec3(0, 0, -100), ...));
///
/// // Remove it
/// scene.remove('card');
/// ```
class ThreeDScene extends ChangeNotifier {
  final Map<String, ThreeDObject> _objects = {};

  // ─── Read ──────────────────────────────────────────────────────────────────

  /// All objects in the scene, unsorted.
  Iterable<ThreeDObject> get all => _objects.values;

  /// Objects sorted back-to-front for the painter's algorithm.
  List<ThreeDObject> get sortedBackToFront =>
      DepthSorter.backToFront(_objects.values.toList());

  /// Objects sorted front-to-back for early-Z culling.
  List<ThreeDObject> get sortedFrontToBack =>
      DepthSorter.frontToBack(_objects.values.toList());

  /// Returns the object with [id], or `null` if not found.
  ThreeDObject? operator [](String id) => _objects[id];

  /// Whether an object with [id] exists.
  bool contains(String id) => _objects.containsKey(id);

  /// The number of objects in the scene.
  int get length => _objects.length;

  // ─── Write ─────────────────────────────────────────────────────────────────

  /// Adds [object] to the scene.
  ///
  /// Throws [StateError] if an object with the same id already exists.
  /// Use [addOrReplace] if upsert semantics are needed.
  void add(ThreeDObject object) {
    if (_objects.containsKey(object.id)) {
      throw StateError(
        'ThreeDScene already contains an object with id "${object.id}". '
        'Use addOrReplace() for upsert semantics.',
      );
    }
    _objects[object.id] = object;
    notifyListeners();
  }

  /// Adds [object], replacing any existing entry with the same id.
  void addOrReplace(ThreeDObject object) {
    _objects[object.id] = object;
    notifyListeners();
  }

  /// Removes the object with [id].
  ///
  /// Returns `true` if the object was found and removed.
  bool remove(String id) {
    final removed = _objects.remove(id) != null;
    if (removed) notifyListeners();
    return removed;
  }

  /// Updates the [Transform3D] of the object identified by [id].
  ///
  /// No-op if no object has that id.
  void updateTransform(String id, Transform3D transform) {
    final existing = _objects[id];
    if (existing == null) return;
    _objects[id] = existing.copyWith(transform: transform);
    notifyListeners();
  }

  /// Replaces the entire object entry for [id].
  ///
  /// No-op if no object has that id.
  void update(ThreeDObject updated) {
    if (!_objects.containsKey(updated.id)) return;
    _objects[updated.id] = updated;
    notifyListeners();
  }

  /// Sets the visibility flag of the object with [id].
  void setVisible(String id, {required bool visible}) {
    final existing = _objects[id];
    if (existing == null) return;
    _objects[id] = existing.copyWith(visible: visible);
    notifyListeners();
  }

  /// Removes all objects from the scene.
  void clear() {
    if (_objects.isEmpty) return;
    _objects.clear();
    notifyListeners();
  }
}
