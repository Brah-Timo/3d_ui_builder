import 'package:flutter/widgets.dart';

import '../foundation/three_d_scene.dart';
import '../foundation/three_d_object.dart';

/// A [StatefulWidget] that listens to a [ThreeDScene] and re-renders its
/// children whenever the scene changes.
///
/// Each [ThreeDObject] in the scene is rendered by calling [itemBuilder],
/// which receives the [BuildContext], the [ThreeDObject] data, and the
/// parent [BoxConstraints].
///
/// Objects are drawn in back-to-front order (painter's algorithm) so that
/// objects with smaller Z values (further away) are painted first.
///
/// ### Example
/// ```dart
/// SceneRenderer(
///   scene: myScene,
///   itemBuilder: (ctx, obj, constraints) {
///     return Positioned(
///       left:  obj.position.x + constraints.maxWidth  / 2,
///       top:   obj.position.y + constraints.maxHeight / 2,
///       child: MyObjectWidget(obj),
///     );
///   },
/// )
/// ```
class SceneRenderer extends StatefulWidget {
  /// The scene to render.
  final ThreeDScene scene;

  /// Builder called for each visible [ThreeDObject] in the scene.
  final Widget Function(
    BuildContext context,
    ThreeDObject object,
    BoxConstraints constraints,
  ) itemBuilder;

  /// Optional background widget placed behind all 3-D objects.
  final Widget? background;

  const SceneRenderer({
    super.key,
    required this.scene,
    required this.itemBuilder,
    this.background,
  });

  @override
  State<SceneRenderer> createState() => _SceneRendererState();
}

class _SceneRendererState extends State<SceneRenderer> {
  @override
  void initState() {
    super.initState();
    widget.scene.addListener(_onSceneChanged);
  }

  @override
  void didUpdateWidget(SceneRenderer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scene != widget.scene) {
      oldWidget.scene.removeListener(_onSceneChanged);
      widget.scene.addListener(_onSceneChanged);
    }
  }

  @override
  void dispose() {
    widget.scene.removeListener(_onSceneChanged);
    super.dispose();
  }

  void _onSceneChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final objects = widget.scene.sortedBackToFront
            .where((o) => o.visible)
            .toList();

        return Stack(
          clipBehavior: Clip.none,
          children: [
            if (widget.background != null) widget.background!,
            ...objects.map(
              (obj) => widget.itemBuilder(ctx, obj, constraints),
            ),
          ],
        );
      },
    );
  }
}
