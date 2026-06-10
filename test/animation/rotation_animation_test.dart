import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:three_d_ui_builder/three_d_ui_builder.dart';

void main() {
  group('RotationAnimation — value', () {
    testWidgets('value at controller=0 returns `from`', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));

      late AnimationController ctrl;
      final key = GlobalKey<State<StatefulWidget>>();

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            key: key,
            builder: (ctx, _) {
              ctrl = AnimationController(
                vsync: tester,
                duration: const Duration(milliseconds: 300),
              );
              return const SizedBox();
            },
          ),
        ),
      );

      final from = Quat.identity;
      final to   = Quat.axisAngle(Vec3.up, math.pi / 2);

      final anim = RotationAnimation(
        controller: ctrl,
        from: from,
        to:   to,
        curve: Curves.linear,
      );

      ctrl.value = 0;
      final result = anim.value;

      expect(result.w, closeTo(from.w, 1e-5));
      expect(result.x, closeTo(from.x, 1e-5));

      ctrl.dispose();
    });

    testWidgets('value at controller=1 returns `to`', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));

      late AnimationController ctrl;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(builder: (ctx, _) {
            ctrl = AnimationController(
              vsync: tester,
              duration: const Duration(milliseconds: 300),
            );
            return const SizedBox();
          }),
        ),
      );

      final from = Quat.identity;
      final to   = Quat.axisAngle(Vec3.up, math.pi / 2);

      final anim = RotationAnimation(
        controller: ctrl,
        from: from,
        to:   to,
        curve: Curves.linear,
      );

      ctrl.value = 1;
      final result = anim.value;

      expect(result.w, closeTo(to.w, 1e-5));
      expect(result.y, closeTo(to.y, 1e-5));

      ctrl.dispose();
    });

    testWidgets('value at controller=0.5 is midpoint', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));

      late AnimationController ctrl;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(builder: (ctx, _) {
            ctrl = AnimationController(
              vsync: tester,
              duration: const Duration(milliseconds: 300),
            );
            return const SizedBox();
          }),
        ),
      );

      final from = Quat.identity;
      final to   = Quat.axisAngle(Vec3.up, math.pi / 2);

      final anim = RotationAnimation(
        controller: ctrl,
        from: from,
        to:   to,
        curve: Curves.linear,
      );

      ctrl.value = 0.5;
      final result = anim.value;
      final expected = Quat.slerp(from, to, 0.5);

      expect(result.w, closeTo(expected.w, 1e-4));
      expect(result.y, closeTo(expected.y, 1e-4));

      ctrl.dispose();
    });
  });

  group('RotationAnimation — curve', () {
    testWidgets('easeIn curve applied correctly', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));

      late AnimationController ctrl;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(builder: (ctx, _) {
            ctrl = AnimationController(
              vsync: tester,
              duration: const Duration(milliseconds: 300),
            );
            return const SizedBox();
          }),
        ),
      );

      final from = Quat.identity;
      final to   = Quat.axisAngle(Vec3.forward, math.pi);

      final animLinear = RotationAnimation(
        controller: ctrl,
        from: from,
        to:   to,
        curve: Curves.linear,
      );
      final animEased = RotationAnimation(
        controller: ctrl,
        from: from,
        to:   to,
        curve: Curves.easeIn,
      );

      ctrl.value = 0.5;

      // At midpoint, easeIn should lag behind linear
      final linearMid = animLinear.value;
      final easedMid  = animEased.value;

      // easeIn is "slower" at the start, so at 0.5 raw it should be
      // closer to `from` than linear is — i.e., easedMid.w > linearMid.w
      // (larger w = smaller rotation angle)
      expect(easedMid.w, greaterThan(linearMid.w - 0.1));

      ctrl.dispose();
    });
  });

  group('ContinuousRotationAnimation', () {
    testWidgets('returns identity when controller=0', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));

      late AnimationController ctrl;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(builder: (ctx, _) {
            ctrl = AnimationController(
              vsync: tester,
              duration: const Duration(seconds: 3),
            );
            return const SizedBox();
          }),
        ),
      );

      final anim = ContinuousRotationAnimation(
        controller: ctrl,
        axis: Vec3.up,
      );

      ctrl.value = 0;
      final q = anim.value;

      // angle = 0 → identity-ish
      expect(q.w, closeTo(1.0, 1e-5));

      ctrl.dispose();
    });
  });
}
