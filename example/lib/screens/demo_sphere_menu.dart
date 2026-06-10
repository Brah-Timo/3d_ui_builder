import 'package:flutter/material.dart';
import 'package:three_d_ui_builder/three_d_ui_builder.dart';

class DemoSphereMenuScreen extends StatefulWidget {
  const DemoSphereMenuScreen({super.key});

  @override
  State<DemoSphereMenuScreen> createState() => _DemoSphereMenuScreenState();
}

class _DemoSphereMenuScreenState extends State<DemoSphereMenuScreen> {
  String _lastTapped = 'None';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          const Text('SphereMenu',
            style: TextStyle(
              color: Colors.cyanAccent, fontSize: 18,
              fontWeight: FontWeight.bold, letterSpacing: 1.5,
            )),
          const SizedBox(height: 8),
          const Text('Drag to rotate  •  Tap items',
            style: TextStyle(color: Colors.white38, fontSize: 12)),
          const SizedBox(height: 32),
          Center(
            child: SphereMenu(
              radius: 140,
              itemSize: 56,
              autoRotate: true,
              autoRotateSpeed: 0.35,
              items: [
                SphereMenuItem(icon: Icons.home,          label: 'Home',     color: const Color(0xFF3F51B5), onTap: () => setState(() => _lastTapped = 'Home')),
                SphereMenuItem(icon: Icons.settings,      label: 'Settings', color: const Color(0xFF607D8B), onTap: () => setState(() => _lastTapped = 'Settings')),
                SphereMenuItem(icon: Icons.person,        label: 'Profile',  color: const Color(0xFF9C27B0), onTap: () => setState(() => _lastTapped = 'Profile')),
                SphereMenuItem(icon: Icons.notifications, label: 'Alerts',   color: const Color(0xFFF44336), onTap: () => setState(() => _lastTapped = 'Alerts')),
                SphereMenuItem(icon: Icons.search,        label: 'Search',   color: const Color(0xFF00BCD4), onTap: () => setState(() => _lastTapped = 'Search')),
                SphereMenuItem(icon: Icons.favorite,      label: 'Likes',    color: const Color(0xFFE91E63), onTap: () => setState(() => _lastTapped = 'Likes')),
                SphereMenuItem(icon: Icons.photo,         label: 'Photos',   color: const Color(0xFF4CAF50), onTap: () => setState(() => _lastTapped = 'Photos')),
                SphereMenuItem(icon: Icons.music_note,    label: 'Music',    color: const Color(0xFFFF9800), onTap: () => setState(() => _lastTapped = 'Music')),
                SphereMenuItem(icon: Icons.map_outlined,  label: 'Maps',     color: const Color(0xFF009688), onTap: () => setState(() => _lastTapped = 'Maps')),
                SphereMenuItem(icon: Icons.star,          label: 'Featured', color: const Color(0xFFFBC02D), onTap: () => setState(() => _lastTapped = 'Featured')),
                SphereMenuItem(icon: Icons.help_outline,  label: 'Help',     color: const Color(0xFF795548), onTap: () => setState(() => _lastTapped = 'Help')),
                SphereMenuItem(icon: Icons.share,         label: 'Share',    color: const Color(0xFF0288D1), onTap: () => setState(() => _lastTapped = 'Share')),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Last tapped: $_lastTapped',
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 40),

          // ── FloatingLabel showcase ─────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text('FloatingLabel + ExtrudedText',
              style: TextStyle(
                color: Colors.cyanAccent, fontSize: 18,
                fontWeight: FontWeight.bold, letterSpacing: 1.5,
              )),
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FloatingLabel('FLOAT', style: const TextStyle(
                color: Colors.cyanAccent, fontSize: 22, fontWeight: FontWeight.bold,
              ), glow: true, glowColor: Colors.cyanAccent),
              FloatingLabel('✦', style: const TextStyle(fontSize: 36),
                amplitude: 10, phaseOffset: 0.33),
              FloatingLabel('3D', style: const TextStyle(
                color: Colors.pinkAccent, fontSize: 22, fontWeight: FontWeight.bold,
              ), glow: true, glowColor: Colors.pinkAccent, phaseOffset: 0.66),
            ],
          ),
          const SizedBox(height: 32),
          ExtrudedText(
            'ULTRA',
            style: const TextStyle(
              fontSize: 52, fontWeight: FontWeight.w900, letterSpacing: 8,
            ),
            depth: 8,
            faceColor: Colors.cyanAccent,
            sideColor: const Color(0xFF006064),
          ),
          const SizedBox(height: 16),
          ExtrudedText(
            '3D',
            style: const TextStyle(
              fontSize: 72, fontWeight: FontWeight.w900, letterSpacing: 12,
            ),
            depth: 12,
            faceColor: Colors.pinkAccent,
            sideColor: const Color(0xFF880E4F),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
