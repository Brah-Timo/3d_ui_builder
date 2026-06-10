import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:three_d_ui_builder/three_d_ui_builder.dart';

void main() {
  group('FlipCard3D', () {
    testWidgets('shows front face initially', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: FlipCard3D(
                front: Text('FRONT', key: Key('front')),
                back:  Text('BACK',  key: Key('back')),
              ),
            ),
          ),
        ),
      );

      // Front should be visible (angle < pi/2 initially)
      expect(find.byKey(const Key('front')), findsOneWidget);
    });

    testWidgets('controller flips to back', (tester) async {
      final ctrl = FlipCard3DController();
      bool flippedToFront = true;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: FlipCard3D(
                controller: ctrl,
                flipDuration: const Duration(milliseconds: 100),
                front: const Text('FRONT', key: Key('front')),
                back:  const Text('BACK',  key: Key('back')),
                onFlipComplete: (isFront) => flippedToFront = isFront,
              ),
            ),
          ),
        ),
      );

      ctrl.flip();
      await tester.pumpAndSettle();

      expect(flippedToFront, false);
    });

    testWidgets('initiallyFlipped starts on back', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: FlipCard3D(
                initiallyFlipped: true,
                front: Text('FRONT'),
                back:  Text('BACK', key: Key('back')),
              ),
            ),
          ),
        ),
      );

      // Back widget should be present when initiallyFlipped
      expect(find.byKey(const Key('back')), findsOneWidget);
    });
  });
}
