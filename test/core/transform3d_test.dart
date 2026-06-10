import 'package:flutter_test/flutter_test.dart';
import 'package:three_d_ui_builder/three_d_ui_builder.dart';

void main() {
  group('Transform3D — identity', () {
    test('identity has zero position', () {
      expect(Transform3D.identity.position, Vec3.zero);
    });

    test('identity has identity rotation', () {
      expect(Transform3D.identity.rotation, Quat.identity);
    });

    test('identity has unit scale', () {
      expect(Transform3D.identity.scale, Vec3.one);
    });

    test('identity toMatrix4 is identity matrix', () {
      final m = Transform3D.identity.toMatrix4();
      // Diagonal should be [1, 1, 1, 1]
      expect(m.storage[0], closeTo(1, 1e-6));
      expect(m.storage[5], closeTo(1, 1e-6));
      expect(m.storage[10], closeTo(1, 1e-6));
      expect(m.storage[15], closeTo(1, 1e-6));
      // Off-diagonal rotation terms should be 0
      expect(m.storage[1], closeTo(0, 1e-6));
      expect(m.storage[4], closeTo(0, 1e-6));
    });
  });

  group('Transform3D — lerp', () {
    test('lerp at t=0 returns this', () {
      const a = Transform3D.identity;
      final b = Transform3D(
        position: const Vec3(100, 0, 0),
        rotation: Quat.identity,
        scale:    Vec3.one,
      );
      expect(a.lerp(b, 0), a);
    });

    test('lerp at t=1 returns other', () {
      const a = Transform3D.identity;
      final b = Transform3D(
        position: const Vec3(100, 0, 0),
        rotation: Quat.identity,
        scale:    Vec3.one,
      );
      expect(a.lerp(b, 1), b);
    });

    test('lerp at t=0.5 midpoints position', () {
      const a = Transform3D.identity;
      final b = Transform3D(
        position: const Vec3(100, 0, 0),
        rotation: Quat.identity,
        scale:    Vec3.one,
      );
      final mid = a.lerp(b, 0.5);
      expect(mid.position.x, closeTo(50, 1e-6));
    });
  });

  group('Transform3D — copyWith', () {
    test('copyWith only changes specified fields', () {
      const t = Transform3D.identity;
      final copied = t.copyWith(position: const Vec3(10, 20, 30));
      expect(copied.position, const Vec3(10, 20, 30));
      expect(copied.rotation, Quat.identity);
      expect(copied.scale,    Vec3.one);
    });
  });

  group('Transform3DTween', () {
    test('lerp at 0.0 returns begin', () {
      final tween = Transform3DTween(
        begin: Transform3D.identity,
        end: Transform3D(
          position: const Vec3(50, 0, 0),
          rotation: Quat.identity,
          scale:    Vec3.one,
        ),
      );
      expect(tween.lerp(0).position, Vec3.zero);
    });

    test('lerp at 1.0 returns end', () {
      final tween = Transform3DTween(
        begin: Transform3D.identity,
        end: Transform3D(
          position: const Vec3(50, 0, 0),
          rotation: Quat.identity,
          scale:    Vec3.one,
        ),
      );
      expect(tween.lerp(1).position.x, closeTo(50, 1e-6));
    });
  });
}
