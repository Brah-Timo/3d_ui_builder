import 'package:flutter_test/flutter_test.dart';
import 'package:three_d_ui_builder/three_d_ui_builder.dart';

void main() {
  group('Vec3 — arithmetic', () {
    test('addition', () {
      const a = Vec3(1, 2, 3);
      const b = Vec3(4, 5, 6);
      expect(a + b, const Vec3(5, 7, 9));
    });

    test('subtraction', () {
      const a = Vec3(4, 5, 6);
      const b = Vec3(1, 2, 3);
      expect(a - b, const Vec3(3, 3, 3));
    });

    test('scalar multiplication', () {
      const a = Vec3(1, 2, 3);
      expect(a * 2, const Vec3(2, 4, 6));
    });

    test('scalar division', () {
      const a = Vec3(2, 4, 6);
      expect(a / 2, const Vec3(1, 2, 3));
    });

    test('negation', () {
      const a = Vec3(1, -2, 3);
      expect(-a, const Vec3(-1, 2, -3));
    });
  });

  group('Vec3 — geometry', () {
    test('length of unit X vector', () {
      expect(Vec3.right.length, closeTo(1, 1e-10));
    });

    test('length of zero vector', () {
      expect(Vec3.zero.length, 0);
    });

    test('normalized returns unit vector', () {
      final n = const Vec3(3, 4, 0).normalized;
      expect(n.length, closeTo(1, 1e-10));
      expect(n.x, closeTo(0.6, 1e-10));
      expect(n.y, closeTo(0.8, 1e-10));
    });

    test('dot product', () {
      expect(Vec3.right.dot(Vec3.up), closeTo(0, 1e-10));
      expect(Vec3.right.dot(Vec3.right), closeTo(1, 1e-10));
    });

    test('cross product', () {
      // right × down = forward (z-positive)
      final c = Vec3.right.cross(Vec3.down);
      expect(c.z, closeTo(1, 1e-10));
    });

    test('lerp at t=0 returns start', () {
      const a = Vec3(0, 0, 0);
      const b = Vec3(10, 10, 10);
      expect(a.lerp(b, 0), a);
    });

    test('lerp at t=1 returns end', () {
      const a = Vec3(0, 0, 0);
      const b = Vec3(10, 10, 10);
      expect(a.lerp(b, 1), b);
    });

    test('lerp at t=0.5', () {
      const a = Vec3(0, 0, 0);
      const b = Vec3(10, 10, 10);
      expect(a.lerp(b, 0.5), const Vec3(5, 5, 5));
    });
  });

  group('Vec3 — equality', () {
    test('equal vectors', () {
      expect(const Vec3(1, 2, 3), const Vec3(1, 2, 3));
    });

    test('unequal vectors', () {
      expect(const Vec3(1, 2, 3) == const Vec3(1, 2, 4), false);
    });

    test('hashCode consistent with equality', () {
      expect(
        const Vec3(1, 2, 3).hashCode,
        const Vec3(1, 2, 3).hashCode,
      );
    });
  });
}
