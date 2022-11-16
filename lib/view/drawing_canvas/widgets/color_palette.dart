import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';

class ColorPalette extends HookWidget {
  final ValueNotifier<Color> selectedColor;

  const ColorPalette({
    Key? key,
    required this.selectedColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Color> colors = [
      Colors.black,
      Colors.white,
      ...Colors.primaries,
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 2,
          runSpacing: 2,
          children: [
            for (Color color in colors)
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => selectedColor.value = color,
                  child: Container(
                    height: 25,
                    width: 25,
                    decoration: BoxDecoration(
                      color: color,
                      border: Border.all(
                          color: selectedColor.value == color
                              ? Colors.blue
                              : Colors.grey,
                          width: 1.5),
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                color: selectedColor.value,
                border: Border.all(color: Colors.blue, width: 1.5),
                borderRadius: const BorderRadius.all(Radius.circular(5)),
              ),
            ),
            const SizedBox(width: 10),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  showColorWheel(context, selectedColor);
                },
                child: SvgPicture.asset(
                  'assets/svgs/color_wheel.svg',
                  height: 30,
                  width: 30,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  showColorWheel(BuildContext context, ValueNotifier<Color> color) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color!'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: color.value,
              onColorChanged: (value) {
                color.value = value;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Done'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }
}
