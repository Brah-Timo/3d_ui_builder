import 'package:flutter/material.dart';
import 'package:three_d_ui_builder/three_d_ui_builder.dart';

class DemoButtonsScreen extends StatefulWidget {
  const DemoButtonsScreen({super.key});

  @override
  State<DemoButtonsScreen> createState() => _DemoButtonsScreenState();
}

class _DemoButtonsScreenState extends State<DemoButtonsScreen> {
  int _pressCount     = 0;
  int _fabPressCount  = 0;
  int _iconPressCount = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _SectionTitle('ThreeDButton'),
          const SizedBox(height: 20),

          // ── Basic 3D button ───────────────────────────────────────────────
          ThreeDButton(
            depth:        10,
            faceColor:    const Color(0xFF5C6BC0),
            borderRadius: 16,
            onPressed: () => setState(() => _pressCount++),
            label: Text(
              'Press Me  ($_pressCount)',
              style: const TextStyle(
                color:      Colors.white,
                fontSize:   16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── Different colours ─────────────────────────────────────────────
          Wrap(
            spacing:  16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              _colorButton('Danger',   const Color(0xFFE53935), depth: 7),
              _colorButton('Success',  const Color(0xFF43A047), depth: 7),
              _colorButton('Warning',  const Color(0xFFFB8C00), depth: 7),
              _colorButton('Disabled', Colors.grey, depth: 7, disabled: true),
            ],
          ),

          const SizedBox(height: 48),
          _SectionTitle('FloatingAction3D'),
          const SizedBox(height: 24),

          // ── FAB ───────────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FloatingAction3D(
                icon:       Icons.add,
                faceColor:  const Color(0xFFE91E63),
                depth:      10,
                size:       64,
                onPressed: () => setState(() => _fabPressCount++),
              ),
              FloatingAction3D(
                icon:      Icons.favorite,
                faceColor: const Color(0xFF9C27B0),
                depth:     8,
                size:      56,
                onPressed: () {},
              ),
              FloatingAction3D(
                icon:      Icons.rocket_launch,
                faceColor: const Color(0xFF0288D1),
                depth:     12,
                size:      72,
                onPressed: () {},
              ),
            ],
          ),

          if (_fabPressCount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'FAB pressed $_fabPressCount times',
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ),

          const SizedBox(height: 48),
          _SectionTitle('IconButton3D'),
          const SizedBox(height: 24),

          Wrap(
            spacing: 24,
            children: [
              IconButton3D(
                icon:          Icons.favorite,
                color:         const Color(0xFFE91E63),
                rotationAxis:  Axis3DRotation.y,
                onPressed: () => setState(() => _iconPressCount++),
              ),
              IconButton3D(
                icon:         Icons.settings,
                color:        const Color(0xFF607D8B),
                rotationAxis: Axis3DRotation.z,
                spinDuration: const Duration(milliseconds: 700),
                onPressed: () {},
              ),
              IconButton3D(
                icon:         Icons.star,
                color:        const Color(0xFFFBC02D),
                rotationAxis: Axis3DRotation.x,
                rotations:    2,
                onPressed: () {},
              ),
            ],
          ),

          if (_iconPressCount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                '❤️ $_iconPressCount',
                style: const TextStyle(color: Colors.pinkAccent, fontSize: 20),
              ),
            ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _colorButton(
    String label,
    Color color, {
    required double depth,
    bool disabled = false,
  }) {
    return ThreeDButton(
      depth:        depth,
      faceColor:    color,
      borderRadius: 12,
      onPressed:    disabled ? null : () {},
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          color:      Colors.cyanAccent,
          fontSize:   18,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
