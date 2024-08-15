import 'package:flutter/material.dart' hide Image;
import 'package:flutter_drawing_board/src/src.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('DrawingCanvas', () {
    testWidgets('renders correctly', (tester) async {
      await tester.pumpWidget(
        const _Seed(
          drawingCanvasOptions: DrawingCanvasOptions(),
        ),
      );
      expect(find.byType(DrawingCanvas), findsOneWidget);
    });

    testWidgets('renders empty canvas', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _Seed(drawingCanvasOptions: DrawingCanvasOptions()),
      );
      await expectLater(
        find.byType(DrawingCanvas),
        matchesGoldenFile('goldens/empty_canvas.png'),
      );
    });
  });

  group('Pencil tool', () {
    testWidgets('draw a single stroke', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _Seed(drawingCanvasOptions: DrawingCanvasOptions()),
      );
      // Simulate drawing
      const Offset startPoint = Offset(100, 100);
      const Offset endPoint = Offset(200, 200);
      await tester.dragFrom(startPoint, endPoint);
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(DrawingCanvas),
        matchesGoldenFile('goldens/single_stroke_canvas.png'),
      );
    });

    testWidgets('draw stroke with a different color',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const _Seed(
          drawingCanvasOptions: DrawingCanvasOptions(strokeColor: redAccent),
        ),
      );
      // Simulate drawing
      const Offset startPoint = Offset(100, 100);
      const Offset endPoint = Offset(200, 200);
      await tester.dragFrom(startPoint, endPoint);
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(DrawingCanvas),
        matchesGoldenFile('goldens/single_stroke_canvas_with_diff_color.png'),
      );
    });
  });

  group('Line Tool', () {
    testWidgets('draws a straight line on the canvas', (tester) async {
      await tester.pumpWidget(
        const _Seed(
          drawingCanvasOptions: DrawingCanvasOptions(
            currentTool: DrawingTool.line,
          ),
        ),
      );

      final screenCenter = tester.getCenter(find.byType(DrawingCanvas));
      final screenHeight = tester.getSize(find.byType(DrawingCanvas)).height;

      // Simulate drawing a line
      final lineStart = Offset(screenCenter.dx, 10);
      final lineEnd = Offset(screenCenter.dx, screenHeight - 10);
      final gesture = await tester.startGesture(lineStart);
      await gesture.moveTo(lineEnd);
      await gesture.up();
      await tester.pumpAndSettle();

      // Compare the result with a golden file or check the canvas state
      await expectLater(
        find.byType(DrawingCanvas),
        matchesGoldenFile('goldens/straight_line.png'),
      );
    });
  });

  group('Ruler tool', () {
    testWidgets('Ruler is active', (tester) async {
      await tester.pumpWidget(
        const _Seed(
          drawingCanvasOptions: DrawingCanvasOptions(
            showGrid: true,
          ),
        ),
      );

      await expectLater(
        find.byType(DrawingCanvas),
        matchesGoldenFile('goldens/ruler_tool_active.png'),
      );
    });
  });

  group('Polygon Tool', () {
    testWidgets('draws a triangle on the canvas', (tester) async {
      await tester.pumpWidget(
        const _Seed(
          drawingCanvasOptions: DrawingCanvasOptions(
            currentTool: DrawingTool.polygon,
            polygonSides: 3,
          ),
        ),
      );

      final screenCenter = tester.getCenter(find.byType(DrawingCanvas));
      final screenHeight = tester.getSize(find.byType(DrawingCanvas)).height;

      // Simulate drawing a triangle
      final triangleStart = Offset(screenCenter.dx, 10);
      final triangleEnd = Offset(screenCenter.dx, screenHeight - 10);
      final gesture = await tester.startGesture(triangleStart);
      await gesture.moveTo(triangleEnd);
      await gesture.up();
      await tester.pumpAndSettle();

      // Compare the result with a golden file or check the canvas state
      await expectLater(
        find.byType(DrawingCanvas),
        matchesGoldenFile('goldens/triangle.png'),
      );
    });

    testWidgets('draws an Octagon on the canvas', (tester) async {
      await tester.pumpWidget(
        const _Seed(
          drawingCanvasOptions: DrawingCanvasOptions(
            currentTool: DrawingTool.polygon,
            polygonSides: 8,
          ),
        ),
      );

      final screenCenter = tester.getCenter(find.byType(DrawingCanvas));
      final screenHeight = tester.getSize(find.byType(DrawingCanvas)).height;

      // Simulate drawing a triangle
      final triangleStart = Offset(screenCenter.dx, 10);
      final triangleEnd = Offset(screenCenter.dx, screenHeight - 10);
      final gesture = await tester.startGesture(triangleStart);
      await gesture.moveTo(triangleEnd);
      await gesture.up();
      await tester.pumpAndSettle();

      // Compare the result with a golden file or check the canvas state
      await expectLater(
        find.byType(DrawingCanvas),
        matchesGoldenFile('goldens/octagon.png'),
      );
    });

    testWidgets('draws a Filled Octagon on the canvas', (tester) async {
      await tester.pumpWidget(
        const _Seed(
          drawingCanvasOptions: DrawingCanvasOptions(
            currentTool: DrawingTool.polygon,
            polygonSides: 8,
            fillShape: true,
          ),
        ),
      );

      final screenCenter = tester.getCenter(find.byType(DrawingCanvas));
      final screenHeight = tester.getSize(find.byType(DrawingCanvas)).height;

      // Simulate drawing a triangle
      final triangleStart = Offset(screenCenter.dx, 10);
      final triangleEnd = Offset(screenCenter.dx, screenHeight - 10);
      final gesture = await tester.startGesture(triangleStart);
      await gesture.moveTo(triangleEnd);
      await gesture.up();
      await tester.pumpAndSettle();

      // Compare the result with a golden file or check the canvas state
      await expectLater(
        find.byType(DrawingCanvas),
        matchesGoldenFile('goldens/octagon_fill.png'),
      );
    });
  });

  group('Circle tool', () {
    testWidgets('draws a circle on the canvas', (tester) async {
      await tester.pumpWidget(
        const _Seed(
          drawingCanvasOptions: DrawingCanvasOptions(
            currentTool: DrawingTool.circle,
          ),
        ),
      );

      final screenCenter = tester.getCenter(find.byType(DrawingCanvas));
      final screenHeight = tester.getSize(find.byType(DrawingCanvas)).height;

      // Simulate drawing a circle
      final circleStart = Offset(screenCenter.dx - 100, 200);
      final circleEnd = Offset(screenCenter.dx + 100, screenHeight - 200);
      final gesture = await tester.startGesture(circleStart);
      await gesture.moveTo(circleEnd);
      await gesture.up();
      await tester.pumpAndSettle();

      // Compare the result with a golden file or check the canvas state
      await expectLater(
        find.byType(DrawingCanvas),
        matchesGoldenFile('goldens/circle.png'),
      );
    });

    testWidgets('draws a filled circle on the canvas', (tester) async {
      await tester.pumpWidget(
        const _Seed(
          drawingCanvasOptions: DrawingCanvasOptions(
            currentTool: DrawingTool.circle,
            fillShape: true,
          ),
        ),
      );

      final screenCenter = tester.getCenter(find.byType(DrawingCanvas));
      final screenHeight = tester.getSize(find.byType(DrawingCanvas)).height;

      // Simulate drawing a circle
      final circleStart = Offset(screenCenter.dx - 100, 200);
      final circleEnd = Offset(screenCenter.dx + 100, screenHeight - 200);
      final gesture = await tester.startGesture(circleStart);
      await gesture.moveTo(circleEnd);
      await gesture.up();
      await tester.pumpAndSettle();

      // Compare the result with a golden file or check the canvas state
      await expectLater(
        find.byType(DrawingCanvas),
        matchesGoldenFile('goldens/circle_fill.png'),
      );
    });
  });

  group('Square tool', () {
    testWidgets('draws a square on the canvas', (tester) async {
      await tester.pumpWidget(
        const _Seed(
          drawingCanvasOptions: DrawingCanvasOptions(
            currentTool: DrawingTool.square,
          ),
        ),
      );

      final screenCenter = tester.getCenter(find.byType(DrawingCanvas));
      final screenHeight = tester.getSize(find.byType(DrawingCanvas)).height;

      // Simulate drawing a square
      final squareStart = Offset(screenCenter.dx - 100, 200);
      final squareEnd = Offset(screenCenter.dx + 100, screenHeight - 200);
      final gesture = await tester.startGesture(squareStart);
      await gesture.moveTo(squareEnd);
      await gesture.up();
      await tester.pumpAndSettle();

      // Compare the result with a golden file or check the canvas state
      await expectLater(
        find.byType(DrawingCanvas),
        matchesGoldenFile('goldens/square.png'),
      );
    });

    testWidgets('draws a filled square on the canvas', (tester) async {
      await tester.pumpWidget(
        const _Seed(
          drawingCanvasOptions: DrawingCanvasOptions(
            currentTool: DrawingTool.square,
            fillShape: true,
          ),
        ),
      );

      final screenCenter = tester.getCenter(find.byType(DrawingCanvas));
      final screenHeight = tester.getSize(find.byType(DrawingCanvas)).height;

      // Simulate drawing a square
      final squareStart = Offset(screenCenter.dx - 100, 200);
      final squareEnd = Offset(screenCenter.dx + 100, screenHeight - 200);
      final gesture = await tester.startGesture(squareStart);
      await gesture.moveTo(squareEnd);
      await gesture.up();
      await tester.pumpAndSettle();

      // Compare the result with a golden file or check the canvas state
      await expectLater(
        find.byType(DrawingCanvas),
        matchesGoldenFile('goldens/square_fill.png'),
      );
    });
  });
}

class _Seed extends StatefulWidget {
  final DrawingCanvasOptions drawingCanvasOptions;

  const _Seed({required this.drawingCanvasOptions});

  @override
  State<_Seed> createState() => _SeedState();
}

class _SeedState extends State<_Seed> {
  final _currentStroke = CurrentStrokeValueNotifier();
  final _strokes = ValueNotifier<List<Stroke>>([]);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: DrawingCanvas(
          canvasKey: GlobalKey(),
          currentStrokeListenable: _currentStroke,
          strokesListenable: _strokes,
          options: widget.drawingCanvasOptions,
        ),
      ),
    );
  }
}
