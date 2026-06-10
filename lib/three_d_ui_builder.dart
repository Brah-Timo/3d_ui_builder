/// # three_d_ui_builder
///
/// Build futuristic 3D UIs with Flutter-native widgets.
/// 3D buttons, flipping cards, circular menus, cube containers — all with
/// a familiar Flutter-style API.  No OpenGL knowledge required.
///
/// ## Quick start
/// ```dart
/// import 'package:three_d_ui_builder/three_d_ui_builder.dart';
///
/// // 3D press button
/// ThreeDButton(
///   label: const Text('Press me'),
///   depth: 8,
///   faceColor: Colors.deepPurple,
///   onPressed: () {},
/// )
///
/// // Flip card
/// FlipCard3D(
///   front: FrontWidget(),
///   back:  BackWidget(),
/// )
///
/// // Circular carousel
/// CircularList3D(
///   itemCount: 6,
///   radius: 200,
///   itemBuilder: (_, i) => ItemCard(i),
///   autoRotate: true,
/// )
/// ```
library three_d_ui_builder;

// ─── Core Math ───────────────────────────────────────────────────────────────
export 'src/core/math/vector3.dart';
export 'src/core/math/quaternion.dart';
export 'src/core/math/matrix4_ext.dart';
export 'src/core/math/transform3d.dart';

// ─── Core Foundation ─────────────────────────────────────────────────────────
export 'src/core/foundation/three_d_object.dart';
export 'src/core/foundation/three_d_scene.dart';
export 'src/core/foundation/depth_sorter.dart';

// ─── Core Engine ─────────────────────────────────────────────────────────────
export 'src/core/engine/canvas_bridge.dart';
export 'src/core/engine/render_pipeline.dart';
export 'src/core/engine/scene_renderer.dart';

// ─── Widgets — Scene ─────────────────────────────────────────────────────────
export 'src/widgets/scene/three_d_scene_widget.dart';
export 'src/widgets/scene/camera_controller.dart';
export 'src/widgets/scene/light_source.dart';

// ─── Widgets — Base ──────────────────────────────────────────────────────────
export 'src/widgets/base/three_d_widget.dart';

// ─── Widgets — Buttons ───────────────────────────────────────────────────────
export 'src/widgets/buttons/three_d_button.dart';
export 'src/widgets/buttons/floating_action_3d.dart';
export 'src/widgets/buttons/icon_button_3d.dart';

// ─── Widgets — Cards ─────────────────────────────────────────────────────────
export 'src/widgets/cards/flip_card_3d.dart';
export 'src/widgets/cards/tilt_card.dart';
export 'src/widgets/cards/depth_card.dart';
export 'src/widgets/cards/parallax_card.dart';

// ─── Widgets — Lists ─────────────────────────────────────────────────────────
export 'src/widgets/lists/circular_list_3d.dart';
export 'src/widgets/lists/cylinder_list.dart';
export 'src/widgets/lists/coverflow_3d.dart';
export 'src/widgets/lists/sphere_menu.dart';

// ─── Widgets — Containers ────────────────────────────────────────────────────
export 'src/widgets/containers/cube_container.dart';
export 'src/widgets/containers/panel_3d.dart';
export 'src/widgets/containers/stack_3d.dart';

// ─── Widgets — Text ──────────────────────────────────────────────────────────
export 'src/widgets/text/extruded_text.dart';
export 'src/widgets/text/floating_label.dart';

// ─── Animation ───────────────────────────────────────────────────────────────
export 'src/animation/rotation_animation.dart';
export 'src/animation/float_animation.dart';
export 'src/animation/flip_animation.dart' hide FlipAxis;
export 'src/animation/spring_3d.dart';

// ─── Gestures ────────────────────────────────────────────────────────────────
export 'src/gestures/drag_3d_recognizer.dart';
export 'src/gestures/pinch_depth_recognizer.dart';
export 'src/gestures/gyroscope_tilt.dart';

// ─── Painters ────────────────────────────────────────────────────────────────
export 'src/painters/shadow_painter_3d.dart';
export 'src/painters/edge_painter.dart';
export 'src/painters/reflection_painter.dart';

// ─── Theme ───────────────────────────────────────────────────────────────────
export 'src/theme/three_d_theme.dart';
export 'src/theme/material_3d.dart';
export 'src/theme/depth_shadow_style.dart';

// ─── Utils ───────────────────────────────────────────────────────────────────
export 'src/utils/perspective_utils.dart';
export 'src/utils/hit_test_3d.dart';
export 'src/utils/debug_overlay.dart';
