import 'package:flutter/widgets.dart';

import '../../core/foundation/three_d_scene.dart';
import '../../core/foundation/three_d_object.dart';
import '../../core/engine/canvas_bridge.dart';
import 'camera_controller.dart';
import 'light_source.dart';

/// The root widget for a widget-based 3-D scene.
///
/// [ThreeDSceneWidget] listens to a [ThreeDScene] model and a [CameraController],
/// rebuilds whenever either changes, and calls [itemBuilder] for each visible
/// [ThreeDObject] to produce the actual Flutter widgets.
///
/// The container is sized to fill its parent.  Object positions are projected
/// from world space to screen space using [CanvasBridge.project] with the
/// camera's focal length.
///
/// ### Usage
/// ```dart
/// ThreeDSceneWidget(
///   scene:  myScene,
///   camera: myCamera,
///   lights: const [LightSource.directional()],
///   itemBuilder: (ctx, obj) => ObjectCard(obj),
/// )
/// ```
class ThreeDSceneWidget extends StatefulWidget {
  final ThreeDScene scene;
  final CameraController camera;
  final List<LightSource> lights;
  final Widget Function(BuildContext, ThreeDObject) itemBuilder;
  final Widget? background;

  const ThreeDSceneWidget({
    super.key,
    required this.scene,
    required this.camera,
    required this.itemBuilder,
    this.lights     = const [LightSource.directional()],
    this.background,
  });

  @override
  State<ThreeDSceneWidget> createState() => _ThreeDSceneWidgetState();
}

class _ThreeDSceneWidgetState extends State<ThreeDSceneWidget> {
  @override
  void initState() {
    super.initState();
    widget.scene.addListener(_rebuild);
    widget.camera.addListener(_rebuild);
  }

  @override
  void didUpdateWidget(ThreeDSceneWidget old) {
    super.didUpdateWidget(old);
    if (old.scene != widget.scene) {
      old.scene.removeListener(_rebuild);
      widget.scene.addListener(_rebuild);
    }
    if (old.camera != widget.camera) {
      old.camera.removeListener(_rebuild);
      widget.camera.addListener(_rebuild);
    }
  }

  @override
  void dispose() {
    widget.scene.removeListener(_rebuild);
    widget.camera.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final size   = Size(constraints.maxWidth, constraints.maxHeight);
        final centre = Offset(size.width / 2, size.height / 2);
        final focal  = widget.camera.distance * 0.8;

        final objects = widget.scene.sortedBackToFront
            .where((o) => o.visible)
            .toList();

        return Stack(
          clipBehavior: Clip.none,
          children: [
            if (widget.background != null)
              Positioned.fill(child: widget.background!),

            ...objects.map((obj) {
              final worldPos = obj.transform.position;

              // Project world → screen
              final screen = CanvasBridge.project(
                worldPos,
                origin:      centre,
                focalLength: focal,
              );

              return Positioned(
                left: screen.dx,
                top:  screen.dy,
                child: widget.itemBuilder(ctx, obj),
              );
            }),
          ],
        );
      },
    );
  }
}
