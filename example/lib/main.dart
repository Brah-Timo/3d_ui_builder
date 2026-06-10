import 'package:flutter/material.dart';
import 'package:three_d_ui_builder/three_d_ui_builder.dart';

import 'screens/demo_buttons.dart';
import 'screens/demo_cards.dart';
import 'screens/demo_circular_list.dart';
import 'screens/demo_cube_scene.dart';
import 'screens/demo_sphere_menu.dart';

void main() => runApp(const DemoApp());

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ThreeDTheme(
      data: ThreeDThemeData.cyberpunk().copyWith(
        defaultDepth: 8,
      ),
      child: MaterialApp(
        title:                   '3D UI Builder Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(useMaterial3: true).copyWith(
          scaffoldBackgroundColor: const Color(0xFF080818),
          colorScheme: ColorScheme.fromSeed(
            seedColor:    Colors.cyanAccent,
            brightness:   Brightness.dark,
          ),
        ),
        home: const DemoHome(),
      ),
    );
  }
}

// ─── Navigation shell ─────────────────────────────────────────────────────────

class DemoHome extends StatefulWidget {
  const DemoHome({super.key});

  @override
  State<DemoHome> createState() => _DemoHomeState();
}

class _DemoHomeState extends State<DemoHome> {
  int _tab = 0;

  static const _tabs = [
    (label: 'Buttons',  icon: Icons.smart_button_outlined),
    (label: 'Cards',    icon: Icons.credit_card_outlined),
    (label: 'Carousel', icon: Icons.rotate_90_degrees_cw_outlined),
    (label: 'Cube',     icon: Icons.view_in_ar_outlined),
    (label: 'Sphere',   icon: Icons.public_outlined),
  ];

  static const _screens = [
    DemoButtonsScreen(),
    DemoCardsScreen(),
    DemoCircularListScreen(),
    DemoCubeScene(),
    DemoSphereMenuScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation:       0,
        title: const Text(
          '🧊 3D UI Builder',
          style: TextStyle(
            fontSize:   20,
            fontWeight: FontWeight.bold,
            color:      Colors.cyanAccent,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: _screens[_tab],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF0D0D24),
        selectedItemColor:   Colors.cyanAccent,
        unselectedItemColor: Colors.white38,
        type:                BottomNavigationBarType.fixed,
        currentIndex:        _tab,
        onTap: (i) => setState(() => _tab = i),
        items: _tabs
            .map((t) => BottomNavigationBarItem(
                  icon:  Icon(t.icon),
                  label: t.label,
                ))
            .toList(),
      ),
    );
  }
}
