import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:three_d_ui_builder/three_d_ui_builder.dart';

void main() {
  group('CircularList3D — rendering', () {
    testWidgets('renders correct number of items', (tester) async {
      const itemCount = 6;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularList3D(
                itemCount: itemCount,
                itemBuilder: (ctx, index) => SizedBox(
                  key: Key('item_$index'),
                  width: 80,
                  height: 80,
                  child: Text('Item $index'),
                ),
                radius: 150,
              ),
            ),
          ),
        ),
      );

      for (var i = 0; i < itemCount; i++) {
        expect(find.byKey(Key('item_$i')), findsOneWidget);
      }
    });

    testWidgets('renders empty widget when itemCount is 0', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularList3D(
                itemCount: 0,
                itemBuilder: (ctx, index) => Text('Item $index'),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('renders with autoRotate enabled without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularList3D(
                itemCount: 4,
                itemBuilder: (ctx, index) => Container(
                  width: 60,
                  height: 60,
                  color: Colors.blue,
                  child: Text('$index'),
                ),
                radius: 120,
                autoRotate: true,
                rotationSpeed: 0.5,
              ),
            ),
          ),
        ),
      );

      // Pump a few frames to allow animation to run
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // All items should still be present
      for (var i = 0; i < 4; i++) {
        expect(find.text('$i'), findsOneWidget);
      }
    });
  });

  group('CircularList3D — parameters', () {
    testWidgets('accepts custom tiltAngle', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularList3D(
                itemCount: 5,
                itemBuilder: (ctx, index) => Text('T$index'),
                radius: 160,
                tiltAngle: 0.6,
              ),
            ),
          ),
        ),
      );

      expect(find.text('T0'), findsOneWidget);
    });

    testWidgets('snapOnRelease does not throw', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularList3D(
                itemCount: 6,
                itemBuilder: (ctx, index) => Text('S$index'),
                radius: 140,
                snapOnRelease: true,
              ),
            ),
          ),
        ),
      );

      // Simulate a horizontal drag
      await tester.drag(find.byType(CircularList3D), const Offset(60, 0));
      await tester.pumpAndSettle();

      expect(find.text('S0'), findsOneWidget);
    });

    testWidgets('counterClockwise direction renders without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularList3D(
                itemCount: 4,
                itemBuilder: (ctx, index) => Text('D$index'),
                radius: 130,
                autoRotate: true,
                rotationDirection: RotationDirection.counterClockwise,
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('D0'), findsOneWidget);
    });
  });

  group('CircularList3D — drag interaction', () {
    testWidgets('horizontal drag updates rotation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularList3D(
                itemCount: 6,
                itemBuilder: (ctx, index) => Container(
                  key: Key('drag_item_$index'),
                  width: 70,
                  height: 70,
                  child: Text('$index'),
                ),
                radius: 150,
              ),
            ),
          ),
        ),
      );

      // Items present before drag
      expect(find.byKey(const Key('drag_item_0')), findsOneWidget);

      // Drag right — ring rotates
      await tester.drag(
        find.byType(CircularList3D),
        const Offset(100, 0),
      );
      await tester.pump();

      // Items should still be rendered (positions changed but all visible)
      expect(find.byKey(const Key('drag_item_0')), findsOneWidget);
    });
  });
}
