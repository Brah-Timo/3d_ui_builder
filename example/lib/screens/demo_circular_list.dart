import 'package:flutter/material.dart';
import 'package:three_d_ui_builder/three_d_ui_builder.dart';

class DemoCircularListScreen extends StatelessWidget {
  const DemoCircularListScreen({super.key});

  static const _items = [
    (label: 'Photos',    icon: Icons.photo_outlined,    color: Color(0xFFE91E63)),
    (label: 'Music',     icon: Icons.music_note,        color: Color(0xFF9C27B0)),
    (label: 'Videos',    icon: Icons.videocam_outlined,  color: Color(0xFF3F51B5)),
    (label: 'Maps',      icon: Icons.map_outlined,       color: Color(0xFF0288D1)),
    (label: 'Files',     icon: Icons.folder_outlined,    color: Color(0xFF009688)),
    (label: 'Settings',  icon: Icons.settings_outlined,  color: Color(0xFF558B2F)),
    (label: 'Calendar',  icon: Icons.calendar_month,     color: Color(0xFFF57C00)),
    (label: 'Contacts',  icon: Icons.contacts_outlined,  color: Color(0xFF795548)),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'CircularList3D',
              style: TextStyle(
                color:      Colors.cyanAccent,
                fontSize:   18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Drag to rotate  •  Items sorted by depth',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ),
          const SizedBox(height: 24),

          // ── Auto-rotating ring ─────────────────────────────────────────────
          CircularList3D(
            itemCount:  _items.length,
            radius:     160,
            tiltAngle:  0.45,
            autoRotate: true,
            rotationSpeed: 0.18,
            itemBuilder: (ctx, i) => _ItemTile(
              label: _items[i].label,
              icon:  _items[i].icon,
              color: _items[i].color,
            ),
          ),

          const SizedBox(height: 48),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'CoverFlow3D',
              style: TextStyle(
                color:      Colors.cyanAccent,
                fontSize:   18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Swipe left / right',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ),
          const SizedBox(height: 24),

          // ── CoverFlow ──────────────────────────────────────────────────────
          CoverFlow3D(
            itemCount:    _items.length,
            itemWidth:    180,
            itemHeight:   180,
            sideAngle:    55,
            spacing:      120,
            initialIndex: 0,
            itemBuilder:  (ctx, i) => _ItemTile(
              label:   _items[i].label,
              icon:    _items[i].icon,
              color:   _items[i].color,
              rounded: true,
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  final String    label;
  final IconData  icon;
  final Color     color;
  final bool      rounded;

  const _ItemTile({
    required this.label,
    required this.icon,
    required this.color,
    this.rounded = false,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color:         color.withAlpha(210),
        borderRadius:  BorderRadius.circular(rounded ? 24 : 14),
        boxShadow: [
          BoxShadow(
            color:      color.withAlpha(80),
            blurRadius: 12,
            offset:     const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color:      Colors.white,
              fontSize:   13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
