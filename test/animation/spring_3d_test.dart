import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:three_d_ui_builder/three_d_ui_builder.dart';

void main() {
  group('Spring3D — presets', () {
    test('Spring3D.snappy has high stiffness', () {
      expect(Spring3D.snappy.stiffness, greaterThan(400));
    });

    test('Spring3D.bouncy has low damping', () {
      expect(Spring3D.bouncy.damping, lessThan(15));
    });

    test('Spring3D.gentle has low stiffness', () {
      expect(Spring3D.gentle.stiffness, lessThan(150));
    });

    test('Spring3D.stiff has very high stiffness', () {
      expect(Spring3D.stiff.stiffness, greaterThan(600));
    });
  });

  group('Spring3D — animate()', () {
    testWidgets('animation value at controller=0 starts near `from`',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));

      late AnimationController ctrl;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(builder: (ctx, _) {
            ctrl = AnimationController(
              vsync: tester,
              duration: const Duration(milliseconds: 600),
            );
            return const SizedBox();
          }),
        ),
      );

      const from = Transform3D.identity;
      final to = Transform3D(
        position: const Vec3(100, 0, 0),
        rotation: Quat.identity,
        scale:    Vec3.one,
      );

      const spring = Spring3D(stiffness: 200, damping: 20);
      final anim = spring.animate(controller: ctrl, from: from, to: to);

      ctrl.value = 0;
      final v = anim.value;

      // At t=0, spring simulation x(0) = 0, so lerp returns `from`
      expect(v.position.x, closeTo(0, 1.0));

      ctrl.dispose();
    });

    testWidgets('animation is valid Animation<Transform3D>', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));

      late AnimationController ctrl;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(builder: (ctx, _) {
            ctrl = AnimationController(
              vsync: tester,
              duration: const Duration(milliseconds: 600),
            );
            return const SizedBox();
          }),
        ),
      );

      final anim = Spring3D.gentle.animate(
        controller: ctrl,
        from: Transform3D.identity,
        to: Transform3D(
          position: const Vec3(0, 50, 0),
          rotation: Quat.identity,
          scale:    Vec3.one,
        ),
      );

      // Confirm it is a proper Animation<Transform3D>
      expect(anim, isA<Animation<Transform3D>>());
      ctrl.dispose();
    });
  });

  group('SpringTransform3D widget', () {
    testWidgets('renders child correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SpringTransform3D(
              targetTransform: Transform3D.identity,
              child: const Text('Spring Child', key: Key('spring_child')),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('spring_child')), findsOneWidget);
    });

    testWidgets('updates when targetTransform changes', (tester) async {
      Transform3D target = Transform3D.identity;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(builder: (ctx, setState) {
              return Column(
                children: [
                  SpringTransform3D(
                    targetTransform: target,
                    child: const Text('Moving'),
                  ),
                  ElevatedButton(
                    key: const Key('move_btn'),
                    onPressed: () {
                      setState(() {
                        target = Transform3D(
                          position: const Vec3(0, -30, 0),
                          rotation: Quat.identity,
                          scale:    Vec3.one,
                        );
                      });
                    },
                    child: const Text('Move'),
                  ),
                ],
              );
            }),
          ),
        ),
      );

      expect(find.text('Moving'), findsOneWidget);

      await tester.tap(find.byKey(const Key('move_btn')));
      await tester.pumpAndSettle();

      expect(find.text('Moving'), findsOneWidget);
    });

    testWidgets('spring preset can be configured', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SpringTransform3D(
              targetTransform: Transform3D.identity,
              spring: Spring3D.snappy,
              child: const Text('Snappy'),
            ),
          ),
        ),
      );

      expect(find.text('Snappy'), findsOneWidget);
    });
  });
}
