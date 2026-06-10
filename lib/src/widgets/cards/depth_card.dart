import 'package:flutter/material.dart';

/// A card built from multiple stacked layers, each rendered at a different
/// physical depth so hovering or tilting reveals genuine 3-D separation.
///
/// Layers are defined with [DepthLayer], which carries the child widget and
/// its depth offset in logical pixels relative to the card surface.
///
/// On hover/press, a subtle perspective tilt is applied so the depth
/// separation becomes visible.
///
/// ### Usage
/// ```dart
/// DepthCard(
///   width: 320,
///   height: 200,
///   layers: [
///     DepthLayer(depth: 0,  child: CardBackground()),
///     DepthLayer(depth: 12, child: CardImage()),
///     DepthLayer(depth: 24, child: CardTitle()),
///     DepthLayer(depth: 36, child: CardBadge()),
///   ],
/// )
/// ```
class DepthCard extends StatefulWidget {
  final double? width;
  final double? height;

  /// The card layers from back (index 0) to front.
  final List<DepthLayer> layers;

  /// Corner radius applied to all layers.
  final double borderRadius;

  /// How far the card tilts on hover/press to reveal depth, in degrees.
  final double hoverTilt;

  /// Duration of the tilt animation.
  final Duration hoverDuration;

  /// Perspective coefficient.
  final double perspective;

  const DepthCard({
    super.key,
    this.width,
    this.height,
    required this.layers,
    this.borderRadius   = 16,
    this.hoverTilt      = 8,
    this.hoverDuration  = const Duration(milliseconds: 300),
    this.perspective    = 0.001,
  });

  @override
  State<DepthCard> createState() => _DepthCardState();
}

class _DepthCardState extends State<DepthCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: widget.hoverDuration,
  );

  late final Animation<double> _tilt = Tween<double>(begin: 0, end: 1).animate(
    CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
  );

  Offset _pointerNorm = Offset.zero;  // normalised [-1, 1]
  Size   _size        = Size.zero;

  void _onEnter(PointerEvent e) {
    _ctrl.forward();
  }

  void _onExit(PointerEvent e) {
    _ctrl.reverse();
  }

  void _onHover(PointerEvent e) {
    final centre = Offset(_size.width / 2, _size.height / 2);
    setState(() {
      _pointerNorm = Offset(
        (e.localPosition.dx - centre.dx) / (_size.width  / 2),
        (e.localPosition.dy - centre.dy) / (_size.height / 2),
      );
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown:  (e) { _onEnter(e); _onHover(e); },
      onPointerMove:  _onHover,
      onPointerUp:    _onExit,
      onPointerCancel: _onExit,
      child: MouseRegion(
        onEnter:  _onEnter,
        onHover:  _onHover,
        onExit:   _onExit,
        child: LayoutBuilder(builder: (ctx, box) {
          _size = Size(
            widget.width  ?? box.maxWidth,
            widget.height ?? box.maxHeight,
          );

          return AnimatedBuilder(
            animation: _tilt,
            builder: (_, __) {
              final t      = _tilt.value;
              final angX   = -_pointerNorm.dy * widget.hoverTilt * t * 3.14159 / 180;
              final angY   =  _pointerNorm.dx * widget.hoverTilt * t * 3.14159 / 180;

              final m = Matrix4.identity()
                ..setEntry(3, 2, widget.perspective)
                ..rotateX(angX)
                ..rotateY(angY);

              return Transform(
                alignment: Alignment.center,
                transform: m,
                child: SizedBox(
                  width:  _size.width,
                  height: _size.height,
                  child: Stack(
                    children: widget.layers.asMap().entries.map((entry) {
                      final layer = entry.value;
                      return _buildDepthLayer(layer, angX, angY, t);
                    }).toList(),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildDepthLayer(DepthLayer layer, double angX, double angY, double t) {
    // Each layer translates by its depth * sin(tilt)
    final shiftX = angY * layer.depth * t;
    final shiftY = angX * layer.depth * t;

    Widget child = layer.child;

    if (layer.clipToCard) {
      child = ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: child,
      );
    }

    return Transform.translate(
      offset: Offset(shiftX, -shiftY),
      child: child,
    );
  }
}

// ─── Supporting types ─────────────────────────────────────────────────────────

/// A single depth layer in a [DepthCard].
class DepthLayer {
  /// Depth offset in logical pixels.  Larger values float further forward.
  final double depth;

  /// The widget rendered at this depth.
  final Widget child;

  /// Whether to clip this layer to the card's rounded corners.
  final bool clipToCard;

  const DepthLayer({
    required this.depth,
    required this.child,
    this.clipToCard = false,
  });
}
