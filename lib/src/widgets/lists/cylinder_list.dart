import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// A scrollable cylindrical picker where items are arranged on the surface of
/// a vertical cylinder.  Items in the centre of the visible arc appear full-
/// size; items toward the edges wrap away and appear smaller with perspective.
///
/// This widget uses a [ListWheelScrollView] under the hood and adds a 3-D
/// perspective overlay.  The [itemBuilder] receives the item index.
///
/// ### Usage
/// ```dart
/// CylinderList(
///   itemCount: 20,
///   itemBuilder: (ctx, i) => ListTile(title: Text('Item $i')),
///   itemExtent: 48,
///   cylinderRadius: 160,
/// )
/// ```
class CylinderList extends StatefulWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  /// Height of each item in logical pixels.
  final double itemExtent;

  /// Radius of the virtual cylinder.  Larger values = flatter curvature.
  final double cylinderRadius;

  /// Optional external scroll controller.
  final FixedExtentScrollController? scrollController;

  /// Clip the overflowing cylinder edges.
  final bool clipToSize;

  /// Whether the list wraps infinitely.
  final bool looping;

  /// Item selector highlight colour.
  final Color? selectorColor;

  final double? height;

  const CylinderList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.itemExtent       = 48,
    this.cylinderRadius   = 160,
    this.scrollController,
    this.clipToSize       = true,
    this.looping          = true,
    this.selectorColor,
    this.height,
  });

  @override
  State<CylinderList> createState() => _CylinderListState();
}

class _CylinderListState extends State<CylinderList> {
  late final FixedExtentScrollController _ctrl =
      widget.scrollController ?? FixedExtentScrollController();

  @override
  void dispose() {
    if (widget.scrollController == null) _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = widget.height ?? widget.itemExtent * 5;

    return SizedBox(
      height: effectiveHeight,
      child: Stack(
        children: [
          // ── Cylinder scroll ──────────────────────────────────────────────
          ListWheelScrollView.useDelegate(
            controller:       _ctrl,
            itemExtent:       widget.itemExtent,
            physics:          const FixedExtentScrollPhysics(),
            perspective:      0.004,
            diameterRatio:    widget.cylinderRadius / (widget.itemExtent * 2),
            offAxisFraction:  0,
            useMagnifier:     false,
            childDelegate:    widget.looping
                ? ListWheelChildLoopingListDelegate(
                    children: List.generate(
                      widget.itemCount,
                      (i) => widget.itemBuilder(context, i),
                    ),
                  )
                : ListWheelChildBuilderDelegate(
                    childCount: widget.itemCount,
                    builder:    widget.itemBuilder,
                  ),
          ),

          // ── Selector highlight ───────────────────────────────────────────
          IgnorePointer(
            child: Center(
              child: Container(
                height:      widget.itemExtent,
                decoration: BoxDecoration(
                  color: (widget.selectorColor ?? Colors.white)
                      .withAlpha(20),
                  border: Border.symmetric(
                    horizontal: BorderSide(
                      color: (widget.selectorColor ?? Colors.white)
                          .withAlpha(80),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Edge fades ───────────────────────────────────────────────────
          IgnorePointer(
            child: Column(
              children: [
                _buildFade(fromTop: true,  height: effectiveHeight * 0.3),
                const Spacer(),
                _buildFade(fromTop: false, height: effectiveHeight * 0.3),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFade({required bool fromTop, required double height}) {
    final theme = Theme.of(context);
    final bg    = theme.scaffoldBackgroundColor;
    return SizedBox(
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin:  fromTop ? Alignment.topCenter    : Alignment.bottomCenter,
            end:    fromTop ? Alignment.bottomCenter : Alignment.topCenter,
            colors: [bg.withAlpha(230), bg.withAlpha(0)],
          ),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}
