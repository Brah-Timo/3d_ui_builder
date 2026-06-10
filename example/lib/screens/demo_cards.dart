import 'package:flutter/material.dart';
import 'package:three_d_ui_builder/three_d_ui_builder.dart';

class DemoCardsScreen extends StatelessWidget {
  const DemoCardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [
          // ── FlipCard3D ─────────────────────────────────────────────────────
          _Label('FlipCard3D  —  tap to flip'),
          const SizedBox(height: 16),
          Center(
            child: FlipCard3D(
              flipDuration: const Duration(milliseconds: 600),
              flipAxis:     FlipAxis.y,
              front: _cardFace(
                label:     'FRONT FACE',
                icon:      Icons.credit_card,
                gradient: const [Color(0xFF3F51B5), Color(0xFF1976D2)],
              ),
              back: _cardFace(
                label:     'BACK FACE',
                icon:      Icons.lock_outline,
                gradient: const [Color(0xFF00897B), Color(0xFF004D40)],
              ),
            ),
          ),

          const SizedBox(height: 40),

          // ── TiltCard ───────────────────────────────────────────────────────
          _Label('TiltCard  —  drag finger across'),
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              width:  320,
              height: 180,
              child: TiltCard(
                maxTilt: 22,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin:  Alignment.topLeft,
                    end:    Alignment.bottomRight,
                    colors: [Color(0xFF4A148C), Color(0xFF7B1FA2)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                parallaxLayers: [
                  ParallaxLayer(
                    depth: 0.0,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end:   Alignment.bottomRight,
                          colors: [Color(0xFF4A148C), Color(0xFF7B1FA2)],
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  ParallaxLayer(
                    depth: 0.4,
                    child: const Center(
                      child: Text(
                        'PARALLAX\nTILT',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color:      Colors.white70,
                          fontSize:   28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                        ),
                      ),
                    ),
                  ),
                  ParallaxLayer(
                    depth: 1.0,
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Icon(
                          Icons.stars,
                          color:  Colors.amber.withAlpha(180),
                          size:   40,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),

          // ── DepthCard ──────────────────────────────────────────────────────
          _Label('DepthCard  —  hover or press'),
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              width:  320,
              height: 180,
              child: DepthCard(
                borderRadius: 20,
                hoverTilt:    14,
                layers: [
                  DepthLayer(
                    depth:       0,
                    clipToCard:  true,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0D0D40), Color(0xFF1A1A60)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  DepthLayer(
                    depth: 20,
                    child: const Center(
                      child: Text(
                        'DEPTH',
                        style: TextStyle(
                          color:      Colors.cyanAccent,
                          fontSize:   32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 8,
                        ),
                      ),
                    ),
                  ),
                  DepthLayer(
                    depth: 40,
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Container(
                          width:  12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.cyanAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),

          // ── ParallaxCard ───────────────────────────────────────────────────
          _Label('ParallaxCard  —  move cursor/finger'),
          const SizedBox(height: 16),
          Center(
            child: ParallaxCard(
              width:          320,
              height:         180,
              parallaxFactor: 0.3,
              enableTilt:     true,
              maxTilt:        14,
              borderRadius:   const BorderRadius.all(Radius.circular(20)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin:  Alignment.topLeft,
                    end:    Alignment.bottomRight,
                    colors: [Color(0xFF1A237E), Color(0xFF006064)],
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.grid_on, color: Colors.white12, size: 120),
                ),
              ),
              foreground: const Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment:  MainAxisAlignment.end,
                  children: [
                    Text(
                      'PARALLAX',
                      style: TextStyle(
                        color:      Colors.white,
                        fontSize:   22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                    ),
                    Text(
                      'Background moves independently',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  static Widget _cardFace({
    required String label,
    required IconData icon,
    required List<Color> gradient,
  }) {
    return Container(
      width:  300,
      height: 180,
      decoration: BoxDecoration(
        gradient:     LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withAlpha(80),
            blurRadius: 20,
            offset:     const Offset(0, 8),
          )
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white70, size: 40),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                color:      Colors.white,
                fontSize:   18,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tap to flip',
              style: TextStyle(color: Colors.white.withAlpha(120), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(
            color:      Colors.cyanAccent,
            fontSize:   14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      );
}
