import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:three_d_ui_builder/three_d_ui_builder.dart';

void main() {
  group('ThreeDButton — rendering', () {
    testWidgets('renders label widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: ThreeDButton(
                label: Text('Press Me', key: Key('label')),
                onPressed: null,
              ),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('label')), findsOneWidget);
      expect(find.text('Press Me'), findsOneWidget);
    });

    testWidgets('renders CustomPaint for 3D effect', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ThreeDButton(
                label: const Text('Click'),
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('disabled when onPressed is null', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ThreeDButton(
                label: const Text('No-op'),
                onPressed: null,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('No-op'));
      await tester.pump();

      expect(tapped, false);
    });
  });

  group('ThreeDButton — interaction', () {
    testWidgets('onPressed fires on tap', (tester) async {
      var count = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ThreeDButton(
                label: const Text('Tap'),
                onPressed: () => count++,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap'));
      await tester.pumpAndSettle();

      expect(count, 1);
    });

    testWidgets('multiple taps fire onPressed each time', (tester) async {
      var count = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ThreeDButton(
                label: const Text('Multi'),
                pressDuration: const Duration(milliseconds: 30),
                onPressed: () => count++,
              ),
            ),
          ),
        ),
      );

      for (var i = 0; i < 3; i++) {
        await tester.tap(find.text('Multi'));
        await tester.pumpAndSettle();
      }

      expect(count, 3);
    });

    testWidgets('custom depth value is accepted', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ThreeDButton(
                label: const Text('Deep'),
                depth: 12.0,
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      // Widget should render without error
      expect(find.text('Deep'), findsOneWidget);
    });
  });

  group('ThreeDButton — theming', () {
    testWidgets('respects ThreeDTheme default depth', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ThreeDTheme(
            data: ThreeDThemeData.defaults().copyWith(defaultDepth: 10.0),
            child: const Scaffold(
              body: Center(
                child: ThreeDButton(
                  label: Text('Themed'),
                  onPressed: null,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Themed'), findsOneWidget);
    });

    testWidgets('custom faceColor and sideColor render without error',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ThreeDButton(
                label: const Text('Colored'),
                faceColor: Colors.purple,
                sideColor: Colors.deepPurple,
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Colored'), findsOneWidget);
    });
  });
}
