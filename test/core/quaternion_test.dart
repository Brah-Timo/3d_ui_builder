import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:three_d_ui_builder/three_d_ui_builder.dart';

void main() {
  group('Quat — construction', () {
    test('identity is unit quaternion', () {
      expect(Quat.identity.magnitude, closeTo(1, 1e-10));
    });

    test('axisAngle 0 radians == identity', () {
      final q = Quat.axisAngle(Vec3.up, 0);
      expect(q.x, closeTo(0, 1e-10));
      expect(q.y, closeTo(0, 1e-10));
      expect(q.z, closeTo(0, 1e-10));
      expect(q.w, closeTo(1, 1e-10));
    });

    test('axisAngle 180° around Y', () {
      final q = Quat.axisAngle(Vec3.up, math.pi);
      // w ≈ 0, y ≈ 1
      expect(q.w, closeTo(0, 1e-6));
      expect(q.y.abs(), closeTo(1, 1e-6));
    });
  });

  group('Quat — rotation', () {
    test('rotate Vec3.right by 90° around Z gives Vec3.down', () {
      final q  = Quat.axisAngle(Vec3.forward, math.pi / 2);
      final r  = q.rotate(Vec3.right);
      // In Flutter coords: right rotated 90° CW around Z = down
      expect(r.x, closeTo(0, 1e-6));
      expect(r.y, closeTo(1, 1e-6));
      expect(r.z, closeTo(0, 1e-6));
    });
  });

  group('Quat — slerp', () {
    test('slerp(a, b, 0) == a', () {
      final a = Quat.axisAngle(Vec3.up, 0);
      final b = Quat.axisAngle(Vec3.up, math.pi / 2);
      final r = Quat.slerp(a, b, 0);
      expect(r.w, closeTo(a.w, 1e-6));
    });

    test('slerp(a, b, 1) == b', () {
      final a = Quat.axisAngle(Vec3.up, 0);
      final b = Quat.axisAngle(Vec3.up, math.pi / 2);
      final r = Quat.slerp(a, b, 1);
      expect(r.y, closeTo(b.y, 1e-6));
      expect(r.w, closeTo(b.w, 1e-6));
    });

    test('slerp(a, b, 0.5) is midpoint rotation', () {
      final a = Quat.axisAngle(Vec3.up, 0);
      final b = Quat.axisAngle(Vec3.up, math.pi / 2);
      final mid = Quat.slerp(a, b, 0.5);
      // Midpoint: 45° around Y
      final expected = Quat.axisAngle(Vec3.up, math.pi / 4);
      expect(mid.w, closeTo(expected.w, 1e-5));
      expect(mid.y, closeTo(expected.y, 1e-5));
    });
  });

  group('Quat — multiplication', () {
    test('identity * identity == identity', () {
      final r = Quat.identity * Quat.identity;
      expect(r.w, closeTo(1, 1e-10));
    });

    test('q * q.inverse ≈ identity', () {
      final q = Quat.axisAngle(Vec3.up, math.pi / 3);
      final r = q * q.inverse;
      expect(r.w, closeTo(1, 1e-6));
      expect(r.x.abs(), lessThan(1e-6));
    });
  });

  group('Quat — axisAngle decomposition', () {
    test('round-trip: axisAngle → decompose', () {
      const inputAngle = 1.2;
      final q          = Quat.axisAngle(Vec3.right, inputAngle);
      final (:axis, angle: decomposedAngle) = q.axisAngle;
      expect(decomposedAngle, closeTo(1.2, 1e-5));
      expect(axis, isNotNull);
    });
  });
}
