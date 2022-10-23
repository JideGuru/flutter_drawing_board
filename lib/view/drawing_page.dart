import 'dart:ui';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter_drawing_board/main.dart';
import 'package:flutter_drawing_board/view/constants.dart';
import 'package:flutter_drawing_board/view/drawing_canvas/drawing_canvas.dart';
import 'package:flutter_drawing_board/view/drawing_canvas/models/drawing_mode.dart';
import 'package:flutter_drawing_board/view/drawing_canvas/models/sketch.dart';
import 'package:flutter_drawing_board/view/drawing_canvas/widgets/canvas_side_bar.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
// ignore: depend_on_referenced_packages
import 'package:vector_math/vector_math_64.dart' show Vector4;

class DrawingPage extends StatefulHookWidget {
  const DrawingPage({Key? key}) : super(key: key);

  @override
  State<DrawingPage> createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  ///Default canvas width.
  late final _kDefaultWidth =
      MediaQuery.of(context).size.width * kDefaultPageCount;

  ///Default canvas height.
  late final _kDefaultHeight =
      MediaQuery.of(context).size.height * kDefaultPageCount;

  ///Minimum sketch point offset.
  ///This holds sketch points along the x and y axes
  ///that are closest to the origin.
  Offset? _minOffset;

  ///Maximum sketch point offsets.
  ///This holds sketch points along the x and y axes
  ///that are furthest from the origin.
  Offset? _maxOffset;

  late final _maxOffsetNotifier = ValueNotifier<Offset?>(_maxOffset);

  ///Reactive drawing canvas width.
  ///[_canvasWidth] may be reset briefly to a smaller value
  ///during image export to extract accurate image renders of the drawing.
  ///This is necessary because there are multiple pages on the canvas and not all might
  ///contain sketches during export. So the export logic shaves off uneccessary whitespace
  ///by temporarily setting [_canvasWidth] to an appropriate value that is large enough
  ///to contain all sketches while remaining as small as possible.
  ///Whenever [_canvasWidth] is reset temporarily for export,
  ///the action is reversed by setting [_canvasWidth] to [_kDefaultWidth] after the export
  ///to restore original dimensions of the drawing canvas.
  late final _canvasWidth = ValueNotifier<double>(_kDefaultWidth);

  ///Reactive drawing canvas height.
  ///[_canvasHeight] may be reset briefly to a smaller value
  ///during image export to extract accurate image renders of the drawing.
  ///This is necessary because there are multiple pages on the canvas and not all might
  ///contain sketches during export. So the export logic shaves off uneccessary whitespace
  ///by temporarily setting [_canvasHeight] to an appropriate value that is large enough
  ///to contain all sketches while remaining as small as possible.
  ///Whenever [_canvasHeight] is reset temporarily for export,
  ///the action is reversed by setting [_canvasHeight] to [_kDefaultHeight] after the export
  ///to restore original dimensions of the drawing canvas.
  late final _canvasHeight = ValueNotifier<double>(_kDefaultHeight);

  ///Notifier whose value is an approximated offset of where some sketches
  ///are drawn on the canvas.
  final _lastContentOffset = ValueNotifier<Offset?>(null);

  ///Notifier whose value indicates whether "Go back to content" button is visible.
  ///Value is `true` when user pans away from visible sketches, otherwise, it's `false`.
  final _canGoBackToContent = ValueNotifier<bool>(false);

  final _currentSketch = ValueNotifier<Sketch?>(null);
  final _allSketches = ValueNotifier<List<Sketch>>([]);
  final _canvasGlobalKey = GlobalKey();

  late final _undoRedoStack = UndoRedoStack(
    sketchesNotifier: _allSketches,
    currentSketchNotifier: _currentSketch,
    onClear: () {
      //reset all pan related state and bring canvas to initial position
      _minOffset = null;
      _maxOffset = null;
      _maxOffsetNotifier.value = null;
      _canvasHeight.value = _kDefaultHeight;
      _canvasWidth.value = _kDefaultWidth;
      _scrollToOrigin();
    },
  );

  ///Controller attached to InteractiveViewer.
  late final _controller = TransformationController();

  ///Listener for InteractiveViewer's pan events.
  void _panListener() {
    if (_minOffset == null || _maxOffset == null) {
      _canGoBackToContent.value = false;
      return;
    }
    final currentdx = _controller.value.row0.w * -1;
    final currentdy = _controller.value.row1.w * -1;

    if (currentdx > _maxOffset!.dx || currentdy > _maxOffset!.dy) {
      //if user has only drawn on the first page and pans to second page,
      //_lastContentOffset's dx and dy values should be 0 to center
      //the canvas on the first page when user clicks to go back to content.
      //Otherwise, settle for x and y points between the furthest (_maxOffset)
      //and closest (_minOffset) offsets to the origin.

      double widthPerPage = _kDefaultWidth / kDefaultPageCount;
      int currentXPage = (currentdx / widthPerPage).ceil();

      double heightPerPage = _kDefaultHeight / kDefaultPageCount;
      int currentYPage = (currentdy / heightPerPage).ceil();

      _lastContentOffset.value = Offset(
        currentXPage <= 2 ? 0 : (_maxOffset!.dx - _minOffset!.dx) * -0.4,
        currentYPage <= 2 ? 0 : (_maxOffset!.dy - _minOffset!.dy) * -0.4,
      );
      _canGoBackToContent.value = true;
    } else {
      _canGoBackToContent.value = false;
      _lastContentOffset.value = null;
    }
  }

  ///Listener attached to [_allSketches].
  ///Checks for new min and max points and updates [_minOffset] and [_maxOffset].
  void _allSketchesListener() {
    if (_minOffset == null ||
        _maxOffset == null ||
        _allSketches.value.isEmpty) {
      return;
    }
    final sketch = _allSketches.value.last;

    for (var point in sketch.points) {
      if (point.dx < _minOffset!.dx) {
        _minOffset = Offset(point.dx, _minOffset!.dy);
      }
      if (point.dy < _minOffset!.dy) {
        _minOffset = Offset(_minOffset!.dx, point.dy);
      }
      if (point.dx > _maxOffset!.dx) {
        _maxOffset = Offset(point.dx, _maxOffset!.dy);
      }
      if (point.dy > _maxOffset!.dy) {
        _maxOffset = Offset(_maxOffset!.dx, point.dy);
      }
    }

    _maxOffsetNotifier.value = _maxOffset;
  }

  ///Listener attached to current sketch notifier.
  void _currentSketchListener() {
    final sketch = _currentSketch.value;
    if (sketch != null) {
      _canGoBackToContent.value = false;
      if (_minOffset == null) {
        //initial offsets
        _minOffset =
            _maxOffset = Offset(sketch.points.first.dx, sketch.points.first.dy);
        _maxOffsetNotifier.value = _maxOffset;
      }
    }
  }

  ///Scrolls to an approximated offset where some sketches might be drawn.
  void _scrollToAreaWithSketches() {
    final offset = _lastContentOffset.value;
    if (offset != null) {
      _canGoBackToContent.value = false;
      _controller.value = Matrix4.columns(
        Vector4(1, 0, 0, 0),
        Vector4(0, 1, 0, 0),
        Vector4(0, 0, 1, 0),
        Vector4(offset.dx, offset.dy, 0, 1),
      );
    }
  }

  ///Scrolls to initial coordinates for InteractiveViewer.
  void _scrollToOrigin() {
    _canGoBackToContent.value = false;
    _controller.value = Matrix4.columns(
      Vector4(1, 0, 0, 0),
      Vector4(0, 1, 0, 0),
      Vector4(0, 0, 1, 0),
      Vector4(0, 0, 0, 1),
    );
  }

  @override
  void initState() {
    super.initState();
    _currentSketch.addListener(_currentSketchListener);
    _allSketches.addListener(_allSketchesListener);
    _controller.addListener(_panListener);
  }

  @override
  void dispose() {
    _undoRedoStack.dispose();
    _currentSketch.removeListener(_currentSketchListener);
    _allSketches.removeListener(_allSketchesListener);
    _controller.removeListener(_panListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = useState(Colors.black);
    final strokeSize = useState<double>(10);
    final eraserSize = useState<double>(30);
    final drawingMode = useState(DrawingMode.pencil);
    final filled = useState<bool>(false);
    final polygonSides = useState<int>(3);
    final backgroundImage = useState<Image?>(null);

    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 150),
      initialValue: 1,
    );

    return Scaffold(
      body: Stack(
        children: [
          ValueListenableBuilder<DrawingMode>(
              valueListenable: drawingMode,
              builder: (_, mode, __) {
                return InteractiveViewer(
                  transformationController: _controller,
                  constrained: false,
                  scaleEnabled: false,
                  //disable panning if _minOffset is null
                  //which indicates there's no sketch on the canvas
                  panEnabled: _minOffset != null && mode == DrawingMode.none,
                  child: MouseRegion(
                    cursor: mode != DrawingMode.none
                        ? SystemMouseCursors.precise
                        : SystemMouseCursors.basic,
                    child: ValueListenableBuilder<double>(
                        valueListenable: _canvasHeight,
                        builder: (_, height, __) {
                          return ValueListenableBuilder<double>(
                              valueListenable: _canvasWidth,
                              builder: (_, width, __) {
                                return Container(
                                  color: kCanvasColor,
                                  width: width,
                                  height: height,
                                  child: DrawingCanvas(
                                    width: width,
                                    height: height,
                                    drawingMode: drawingMode,
                                    selectedColor: selectedColor,
                                    strokeSize: strokeSize,
                                    eraserSize: eraserSize,
                                    sideBarController: animationController,
                                    currentSketch: _currentSketch,
                                    allSketches: _allSketches,
                                    canvasGlobalKey: _canvasGlobalKey,
                                    filled: filled,
                                    polygonSides: polygonSides,
                                    backgroundImage: backgroundImage,
                                  ),
                                );
                              });
                        }),
                  ),
                );
              }),
          Positioned(
            top: kToolbarHeight + 10,
            // left: -5,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-1, 0),
                end: Offset.zero,
              ).animate(animationController),
              child: CanvasSideBar(
                drawingMode: drawingMode,
                selectedColor: selectedColor,
                strokeSize: strokeSize,
                eraserSize: eraserSize,
                currentSketch: _currentSketch,
                allSketches: _allSketches,
                canvasGlobalKey: _canvasGlobalKey,
                filled: filled,
                polygonSides: polygonSides,
                backgroundImage: backgroundImage,
                canvasWidth: _canvasWidth,
                canvasHeight: _canvasHeight,
                maxOffset: _maxOffsetNotifier,
                defaultCanvasWidth: _kDefaultWidth,
                defaultCanvasHeight: _kDefaultHeight,
                undoRedoStack: _undoRedoStack,
              ),
            ),
          ),
          _CustomAppBar(animationController: animationController),
          Positioned(
            bottom: 40,
            left: MediaQuery.of(context).size.width * .45,
            child: ValueListenableBuilder<bool>(
                valueListenable: _canGoBackToContent,
                builder: (_, canScroll, __) {
                  if (!canScroll) return const SizedBox();
                  return TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(200, 45),
                    ),
                    onPressed: _scrollToAreaWithSketches,
                    child: const Text("Scroll back to content"),
                  );
                }),
          ),
        ],
      ),
    );
  }
}

class _CustomAppBar extends StatelessWidget {
  final AnimationController animationController;

  const _CustomAppBar({Key? key, required this.animationController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kToolbarHeight,
      width: double.maxFinite,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                if (animationController.value == 0) {
                  animationController.forward();
                } else {
                  animationController.reverse();
                }
              },
              icon: const Icon(Icons.menu),
            ),
            const Text(
              'Let\'s Draw',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 19,
              ),
            ),
            const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

///A data structure for undoing and redoing sketches.
class UndoRedoStack {
  UndoRedoStack({
    required this.sketchesNotifier,
    required this.currentSketchNotifier,
    required this.onClear,
  }) {
    _sketchCount = sketchesNotifier.value.length;
    sketchesNotifier.addListener(_sketchesCountListener);
  }

  final VoidCallback onClear;

  final ValueNotifier<List<Sketch>> sketchesNotifier;
  final ValueNotifier<Sketch?> currentSketchNotifier;

  ///Collection of sketches that can be redone.
  late final List<Sketch> _redoStack = [];

  ///Whether redo operation is possible.
  ValueNotifier<bool> get canRedo => _canRedo;
  late final ValueNotifier<bool> _canRedo = ValueNotifier(false);

  late int _sketchCount;

  void _sketchesCountListener() {
    if (sketchesNotifier.value.length > _sketchCount) {
      //if a new sketch is drawn,
      //history is invalidated so clear redo stack
      _redoStack.clear();
      _canRedo.value = false;
      _sketchCount = sketchesNotifier.value.length;
    }
  }

  void clear() {
    _sketchCount = 0;
    sketchesNotifier.value = [];
    _canRedo.value = false;
    currentSketchNotifier.value = null;
    onClear();
  }

  void undo() {
    final sketches = List<Sketch>.from(sketchesNotifier.value);
    if (sketches.isNotEmpty) {
      _sketchCount--;
      _redoStack.add(sketches.removeLast());
      sketchesNotifier.value = sketches;
      _canRedo.value = true;
      currentSketchNotifier.value = null;
    }
  }

  void redo() {
    if (_redoStack.isEmpty) return;
    final sketch = _redoStack.removeLast();
    _canRedo.value = _redoStack.isNotEmpty;
    _sketchCount++;
    sketchesNotifier.value = [...sketchesNotifier.value, sketch];
  }

  void dispose() {
    sketchesNotifier.removeListener(_sketchesCountListener);
  }
}
