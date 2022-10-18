import 'dart:ui' as ui;

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_drawing_board/view/drawing_canvas/models/drawing_mode.dart';
import 'package:flutter_drawing_board/view/drawing_canvas/models/sketch.dart';
import 'package:flutter_drawing_board/view/drawing_canvas/widgets/color_palette.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CanvasSideBar extends StatelessWidget {
  final ValueNotifier<Color> selectedColor;
  final ValueNotifier<double> strokeSize;
  final ValueNotifier<double> eraserSize;
  final ValueNotifier<DrawingMode> drawingMode;
  final ValueNotifier<Sketch?> currentSketch;
  final ValueNotifier<List<Sketch>> allSketches;
  final GlobalKey canvasGlobalKey;

  const CanvasSideBar({
    Key? key,
    required this.selectedColor,
    required this.strokeSize,
    required this.eraserSize,
    required this.drawingMode,
    required this.currentSketch,
    required this.allSketches,
    required this.canvasGlobalKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 3,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text(
              'Shapes',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Wrap(
              alignment: WrapAlignment.start,
              spacing: 5,
              runSpacing: 5,
              children: [
                _IconBox(
                  iconData: FontAwesomeIcons.pencil,
                  selected: drawingMode.value == DrawingMode.pencil,
                  onTap: () => drawingMode.value = DrawingMode.pencil,
                ),
                _IconBox(
                  selected: drawingMode.value == DrawingMode.line,
                  onTap: () => drawingMode.value = DrawingMode.line,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 22,
                        height: 2,
                        color: drawingMode.value == DrawingMode.line
                            ? Colors.grey[900]
                            : Colors.grey,
                      ),
                    ],
                  ),
                ),
                _IconBox(
                  iconData: FontAwesomeIcons.eraser,
                  selected: drawingMode.value == DrawingMode.eraser,
                  onTap: () => drawingMode.value = DrawingMode.eraser,
                ),
                _IconBox(
                  iconData: FontAwesomeIcons.solidSquare,
                  selected: drawingMode.value == DrawingMode.squareFilled,
                  onTap: () => drawingMode.value = DrawingMode.squareFilled,
                ),
                _IconBox(
                  iconData: FontAwesomeIcons.square,
                  selected: drawingMode.value == DrawingMode.squareOutline,
                  onTap: () => drawingMode.value = DrawingMode.squareOutline,
                ),
                _IconBox(
                  iconData: FontAwesomeIcons.solidCircle,
                  selected: drawingMode.value == DrawingMode.circleFilled,
                  onTap: () => drawingMode.value = DrawingMode.circleFilled,
                ),
                _IconBox(
                  iconData: FontAwesomeIcons.circle,
                  selected: drawingMode.value == DrawingMode.circleOutline,
                  onTap: () => drawingMode.value = DrawingMode.circleOutline,
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Colors',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ColorPalette(
              selectedColor: selectedColor,
            ),
            const SizedBox(height: 20),
            const Text(
              'Size',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Row(
              children: [
                const Text(
                  'Stroke Size: ',
                  style: TextStyle(fontSize: 12),
                ),
                Slider(
                  value: strokeSize.value,
                  min: 0,
                  max: 50,
                  onChanged: (val) {
                    strokeSize.value = val;
                  },
                ),
              ],
            ),
            Row(
              children: [
                const Text(
                  'Eraser Size: ',
                  style: TextStyle(fontSize: 12),
                ),
                Slider(
                  value: eraserSize.value,
                  min: 0,
                  max: 80,
                  onChanged: (val) {
                    eraserSize.value = val;
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Actions',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Row(
              children: [
                TextButton(
                  child: const Text('Undo'),
                  onPressed: () {},
                ),
                TextButton(
                  child: const Text('Redo'),
                  onPressed: () {},
                ),
                TextButton(
                  child: const Text('Clear'),
                  onPressed: () {
                    allSketches.value = List.from(allSketches.value)..clear();
                    currentSketch.value = null;
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Export',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Row(
              children: [
                SizedBox(
                  width: 140,
                  child: TextButton(
                    child: const Text('Export PNG'),
                    onPressed: () async {
                      try {
                        Uint8List? pngBytes = await getBytes();

                        if (pngBytes != null) {
                          await FileSaver.instance.saveFile(
                            'FlutterLetsDraw-${DateTime.now().toIso8601String()}.png',
                            pngBytes,
                            'png',
                            mimeType: MimeType.PNG,
                          );
                        }
                      } catch (e) {
                        print(e);
                      }
                    },
                  ),
                ),
                SizedBox(
                  width: 140,
                  child: TextButton(
                    child: const Text('Export SVG'),
                    onPressed: () async {
                      try {
                        Uint8List? pngBytes = await getBytes();
                        print('Not implemented');
                      } catch (e) {
                        print(e);
                      }
                    },
                  ),
                ),
              ],
            ),
            // add about me button or follow buttons
            const Divider(),
            Center(
              child: const Text(
                'Made with 💙 by JideGuru',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Uint8List?> getBytes() async  {
    RenderRepaintBoundary boundary =
    canvasGlobalKey.currentContext?.findRenderObject()
    as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png);
    Uint8List? pngBytes = byteData?.buffer.asUint8List();
    return pngBytes;
  }
}

class _IconBox extends StatelessWidget {
  final IconData? iconData;
  final Widget? child;
  final bool selected;
  final VoidCallback onTap;

  const _IconBox({
    Key? key,
    this.iconData,
    this.child,
    required this.selected,
    required this.onTap,
  })  : assert(child != null || iconData != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 35,
        width: 35,
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? Colors.grey[900]! : Colors.grey,
            width: 1.5,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(5)),
        ),
        child: child ??
            Icon(
              iconData,
              color: selected ? Colors.grey[900] : Colors.grey,
              size: 20,
            ),
      ),
    );
  }
}
