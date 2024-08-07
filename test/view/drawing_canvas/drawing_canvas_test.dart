import 'dart:ui';

import 'package:flutter/material.dart' hide Image;
import 'package:flutter_drawing_board/view/drawing_canvas/drawing_canvas.dart';
import 'package:flutter_drawing_board/view/drawing_canvas/models/drawing_mode.dart';
import 'package:flutter_drawing_board/view/drawing_canvas/models/sketch.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Drawing Canvas', () {
    testWidgets('renders correctly', (tester) async {
      await tester.pumpWidget(
        const _Seed(),
      );
      expect(find.byType(DrawingCanvas), findsOneWidget);
    });

    testWidgets('renders empty canvas', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _Seed(),
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
        const _Seed(),
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
        _Seed(
          selectedColor: ValueNotifier(Colors.red),
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

  group('Eraser tool', () {
    testWidgets('erase a stroke', (WidgetTester tester) async {
      await tester.pumpWidget(
        _Seed(
          strokeSize: ValueNotifier(10),
          eraserSize: ValueNotifier(5),
        ),
      );
      // Simulate drawing a stroke
      const Offset startPoint = Offset(100, 100);
      const Offset endPoint = Offset(200, 200);
      await tester.dragFrom(startPoint, endPoint);
      await tester.pumpAndSettle();

      // Switch to eraser mode
      final _SeedState state = tester.state(find.byType(_Seed));
      state.drawingMode.value = DrawingMode.eraser;

      // Erase part of the stroke
      const Offset eraseStartPoint = Offset(150, 150);
      const Offset eraseEndPoint = Offset(200, 200);
      await tester.dragFrom(eraseStartPoint, eraseEndPoint);
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(DrawingCanvas),
        matchesGoldenFile('goldens/erased_stroke_canvas.png'),
      );
    });
  });

  group('Polygon tool', () {
    testWidgets('draw a polygon', (WidgetTester tester) async {
      await tester.pumpWidget(
        _Seed(
          polygonSides: ValueNotifier(5),
          drawingMode: ValueNotifier(DrawingMode.polygon),
        ),
      );

      // Simulate drawing a polygon
      const Offset startPoint = Offset(100, 100);
      const Offset endPoint = Offset(200, 200);
      await tester.dragFrom(startPoint, endPoint);
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(DrawingCanvas),
        matchesGoldenFile('goldens/polygon_canvas.png'),
      );
    });

    testWidgets('draw a filled polygon', (WidgetTester tester) async {
      await tester.pumpWidget(
        _Seed(
          drawingMode: ValueNotifier(DrawingMode.polygon),
          polygonSides: ValueNotifier(5),
          filled: ValueNotifier(true),
        ),
      );

      // Simulate drawing a filled polygon
      const Offset startPoint = Offset(100, 100);
      const Offset endPoint = Offset(200, 200);
      await tester.dragFrom(startPoint, endPoint);
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(DrawingCanvas),
        matchesGoldenFile('goldens/filled_polygon_canvas.png'),
      );
    });
  });
}

class _Seed extends StatefulWidget {
  final ValueNotifier<Color>? selectedColor;
  final ValueNotifier<double>? strokeSize;
  final ValueNotifier<double>? eraserSize;
  final ValueNotifier<DrawingMode>? drawingMode;
  final ValueNotifier<int>? polygonSides;
  final ValueNotifier<bool>? filled;

  const _Seed({
    Key? key,
    this.selectedColor,
    this.strokeSize,
    this.eraserSize,
    this.drawingMode,
    this.polygonSides,
    this.filled,
  }) : super(key: key);

  @override
  State<_Seed> createState() => _SeedState();
}

class _SeedState extends State<_Seed> {
  final ValueNotifier<Color> selectedColor = ValueNotifier<Color>(Colors.black);
  final ValueNotifier<double> strokeSize = ValueNotifier<double>(5.0);
  final ValueNotifier<double> eraserSize = ValueNotifier<double>(5.0);
  final ValueNotifier<DrawingMode> drawingMode =
      ValueNotifier<DrawingMode>(DrawingMode.pencil);
  final ValueNotifier<Sketch?> currentSketch = ValueNotifier<Sketch?>(null);
  final ValueNotifier<List<Sketch>> allSketches =
      ValueNotifier<List<Sketch>>([]);
  final ValueNotifier<int> polygonSides = ValueNotifier<int>(3);
  final ValueNotifier<bool> filled = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: DrawingCanvas(
          selectedColor: widget.selectedColor ?? selectedColor,
          strokeSize: widget.strokeSize ?? strokeSize,
          eraserSize: widget.eraserSize ?? eraserSize,
          drawingMode: widget.drawingMode ?? drawingMode,
          currentSketch: currentSketch,
          allSketches: allSketches,
          canvasGlobalKey: GlobalKey(),
          filled: widget.filled ?? filled,
          polygonSides: widget.polygonSides ?? polygonSides,
          backgroundImage: ValueNotifier<Image?>(null),
        ),
      ),
    );
  }
}
