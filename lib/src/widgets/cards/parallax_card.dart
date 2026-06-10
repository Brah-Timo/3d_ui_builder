import 'package:flutter/material.dart';

/// A card whose background and content move at different speeds as the
/// user tilts or drags, producing a window-through-a-scene parallax illusion.
///
/// The background shifts opposite to the pointer direction (as if you were
/// looking through a window into a moving scene), while the foreground
/// content can optionally shift in the same direction to stay stationary.
///
/// ### Usage
/// ```dart
/// ParallaxCard(
///   background: Image.asset('assets/space.jpg', fit: BoxFit.cover),
///   foreground: CardContentWidget(),
///   parallaxFactor: 0.3,   // background moves 30% of the pointer offset
///   width:  320,
///   height: 200,
/// )
/// ```
class ParallaxCard extends StatefulWidget {
  /// The background widget — typically a large image.
  final Widget background;

  /// The foreground content layer.
  final Widget? foreground;

  /// An optional middle-ground layer that moves at 50% of [parallaxFactor].
  final Widget? midground;

  /// How strongly the background shifts per unit of pointer movement.
  /// `0` = no movement; `1` = full pointer delta applied to background.
  final double parallaxFactor;

  /// Whether to apply a tilt transform to the card surface itself.
  final bool enableTilt;

  /// Maximum card tilt in degrees (only relevant when [enableTilt] is true).
  final double maxTilt;

  final double? width;
  final double? height;
  final BorderRadius borderRadius;

  /// Border/shadow decoration of the card container.
  final BoxDecoration? decoration;

  const ParallaxCard({
    super.key,
    required this.background,
    this.foreground,
    this.midground,
    this.parallaxFactor = 0.25,
    this.enableTilt     = true,
    this.maxTilt        = 12.0,
    this.width,
    this.height,
    this.borderRadius   = const BorderRadius.all(Radius.circular(20)),
    this.decoration,
  });

  @override
  State<ParallaxCard> createState() => _ParallaxCardState();
}

class _ParallaxCardState extends State<ParallaxCard>
    with SingleTickerProviderStateMixin {
  Offset _norm   = Offset.zero;  // normalised pointer position [-1, 1]
  Size   _size   = Size.zero;

  late final AnimationController _returnCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  late Animation<Offset> _returnAnim =
      const AlwaysStoppedAnimation(Offset.zero);

  Offset _displayNorm = Offset.zero;

  void _updatePointer(Offset local) {
    if (_size == Size.zero) return;
    _returnCtrl.stop();
    final centre = Offset(_size.width / 2, _size.height / 2);
    setState(() {
      _norm         = Offset(
        (local.dx - centre.dx) / (_size.width  / 2),
        (local.dy - centre.dy) / (_size.height / 2),
      );
      _displayNorm = _norm;
    });
  }

  void _startReturn() {
    final from = _norm;
    _returnAnim = Tween<Offset>(begin: from, end: Offset.zero).animate(
      CurvedAnimation(parent: _returnCtrl, curve: Curves.elasticOut),
    )..addListener(() {
        if (mounted) setState(() {
          _displayNorm = _returnAnim.value;
          _norm        = _returnAnim.value;
        });
      });
    _returnCtrl.forward(from: 0);
  }

  @override
  void dispose() {
    _returnCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final decoration = widget.decoration ??
        BoxDecoration(
          borderRadius: widget.borderRadius,
          boxShadow: const [
            BoxShadow(
              color:      Color(0x33000000),
              blurRadius: 24,
              offset:     Offset(0, 10),
            )
          ],
        );

    return Listener(
      onPointerMove:   (e) => _updatePointer(e.localPosition),
      onPointerUp:     (_) => _startReturn(),
      onPointerCancel: (_) => _startReturn(),
      child: MouseRegion(
        onHover: (e) => _updatePointer(e.localPosition),
        onExit:  (_) => _startReturn(),
        child: LayoutBuilder(builder: (ctx, box) {
          _size = Size(
            widget.width  ?? box.maxWidth,
            widget.height ?? box.maxHeight,
          );

          final bgShift   = _displayNorm * (_size.width * widget.parallaxFactor);
          final midShift  = bgShift * 0.5;

          Matrix4 tiltM = Matrix4.identity();
          if (widget.enableTilt) {
            final angX = -_displayNorm.dy * widget.maxTilt * 3.14159 / 180;
            final angY =  _displayNorm.dx * widget.maxTilt * 3.14159 / 180;
            tiltM = Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(angX)
              ..rotateY(angY);
          }

          return Transform(
            alignment: Alignment.center,
            transform: tiltM,
            child: Container(
              width:       _size.width,
              height:      _size.height,
              decoration:  decoration,
              clipBehavior: Clip.hardEdge,
              child: Stack(
                fit:      StackFit.expand,
                children: [
                  // Background — moves most
                  Transform.translate(
                    offset: -bgShift,
                    child: widget.background,
                  ),

                  // Midground — moves at half rate
                  if (widget.midground != null)
                    Transform.translate(
                      offset: -midShift,
                      child: widget.midground,
                    ),

                  // Foreground — stays put (counter-shifts the tilt)
                  if (widget.foreground != null) widget.foreground!,
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
