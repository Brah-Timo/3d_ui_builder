import 'package:flutter/material.dart';
import 'package:three_d_ui_builder/three_d_ui_builder.dart';

class DemoCubeScene extends StatefulWidget {
  const DemoCubeScene({super.key});

  @override
  State<DemoCubeScene> createState() => _DemoCubeSceneState();
}

class _DemoCubeSceneState extends State<DemoCubeScene> {
  final _controller = CubeController();
  CubeFace _currentFace = CubeFace.front;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [
          const Text(
            'CubeContainer',
            style: TextStyle(
              color: Colors.cyanAccent, fontSize: 18,
              fontWeight: FontWeight.bold, letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Drag to rotate  •  Tap buttons to snap',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
          const SizedBox(height: 32),
          Center(
            child: CubeContainer(
              size:        260,
              controller:  _controller,
              onFaceVisible: (f) => setState(() => _currentFace = f),
              front:  _CubeFace('HOME',     Icons.home,     const Color(0xFF3F51B5)),
              back:   _CubeFace('SETTINGS', Icons.settings, const Color(0xFF4CAF50)),
              left:   _CubeFace('PROFILE',  Icons.person,   const Color(0xFF9C27B0)),
              right:  _CubeFace('ALERTS',   Icons.notifications, const Color(0xFFF44336)),
              top:    _CubeFace('SEARCH',   Icons.search,   const Color(0xFF00BCD4)),
              bottom: _CubeFace('HELP',     Icons.help,     const Color(0xFFFF9800)),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Visible face: ${_currentFace.name.toUpperCase()}',
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 10, runSpacing: 10,
            alignment: WrapAlignment.center,
            children: CubeFace.values.map((face) {
              final active = _currentFace == face;
              return TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: active
                      ? Colors.cyanAccent.withAlpha(40)
                      : Colors.white10,
                  side: BorderSide(
                    color: active ? Colors.cyanAccent : Colors.white24,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => _controller.showFace(face),
                child: Text(
                  face.name.toUpperCase(),
                  style: TextStyle(
                    color: active ? Colors.cyanAccent : Colors.white54,
                    fontSize: 12,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 40),
          const Text(
            'Panel3D',
            style: TextStyle(
              color: Colors.cyanAccent, fontSize: 18,
              fontWeight: FontWeight.bold, letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Panel3D(
            width: 300, height: 140,
            tiltX: 4, tiltY: -6,
            edgeDepth: 10,
            color: const Color(0xFF1A1A3A),
            child: const Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('DASHBOARD',
                    style: TextStyle(
                      color: Colors.cyanAccent, fontSize: 14,
                      fontWeight: FontWeight.bold, letterSpacing: 3,
                    )),
                  SizedBox(height: 8),
                  Text('Panel3D with tiltX=4°, tiltY=-6°',
                    style: TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CubeFace extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _CubeFace(this.label, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color.withAlpha(200),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 48),
          const SizedBox(height: 10),
          Text(label,
            style: const TextStyle(
              color: Colors.white, fontSize: 18,
              fontWeight: FontWeight.bold, letterSpacing: 2,
            )),
        ],
      ),
    );
  }
}
