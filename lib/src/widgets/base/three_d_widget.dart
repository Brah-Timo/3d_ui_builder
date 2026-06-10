import 'package:flutter/widgets.dart';

import '../../core/math/transform3d.dart';
import '../../theme/three_d_theme.dart';

/// Abstract base class for every [three_d_ui_builder] widget that lives in
/// 3-D space.
///
/// Subclasses receive the current [ThreeDThemeData] from the widget tree and
/// a [Transform3D] describing their position, rotation, and scale.
///
/// Subclasses **must** override [build3D] instead of [build].
///
/// ```dart
/// class MyWidget3D extends ThreeDWidget {
///   const MyWidget3D({super.key, super.transform});
///
///   @override
///   Widget build3D(BuildContext context, ThreeDThemeData theme) {
///     return Container(color: theme.defaultMaterial.color);
///   }
/// }
/// ```
abstract class ThreeDWidget extends StatelessWidget {
  /// The initial spatial transform.  Defaults to [Transform3D.identity].
  final Transform3D transform;

  const ThreeDWidget({
    super.key,
    this.transform = Transform3D.identity,
  });

  /// Override this instead of [build].
  ///
  /// [theme] is the nearest [ThreeDTheme] data in the widget tree,
  /// falling back to [ThreeDThemeData.defaults] if none is found.
  Widget build3D(BuildContext context, ThreeDThemeData theme);

  @override
  Widget build(BuildContext context) {
    final theme = ThreeDTheme.of(context);
    return build3D(context, theme);
  }
}
