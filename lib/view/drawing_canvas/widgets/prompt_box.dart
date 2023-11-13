import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:http/http.dart' as http;

class PromptBox extends HookWidget {
  final GlobalKey canvasGlobalKey;
  final ValueNotifier<ui.Image?> backgroundImage;

  const PromptBox({
    Key? key,
    required this.canvasGlobalKey,
    required this.backgroundImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageSizeRatio =
        MediaQuery.of(context).size.width / MediaQuery.of(context).size.height;

    final textController = useTextEditingController();
    final text = useState('');
    final isLoading = useState(false);
    final responseText = useState('');

    Future<void> _txt2img() async {
      isLoading.value = true;

      final apiUrl = Uri.parse('http://192.168.1.84:7860/sdapi/v1/txt2img');

      final Map<String, String> headers = {
        'Content-Type': 'application/json',
      };

      final width = 512 * imageSizeRatio;

      final Map<String, dynamic> requestBody = {
        "prompt": text.value,
        "batch_size": 1,
        "steps": 20,
        "width": width,
        "height": 512,
        "cfg_scale": 7,
      };

      final String requestBodyJson = jsonEncode(requestBody);

      try {
        final response = await http.post(
          apiUrl,
          headers: headers,
          body: requestBodyJson,
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          responseText.value = "success";

          final imageBytes = base64Decode(data['images'][0]);
          backgroundImage.value = await decodeImageFromList(imageBytes);
        } else {
          responseText.value = 'Error: ${response.statusCode}';
        }
      } catch (e) {
        responseText.value = 'Error: $e';
      } finally {
        isLoading.value = false;
      }
    }

    Future<void> _img2img() async {
      isLoading.value = true;

      // get the encoded canvas
      final encodedCanvas = await getEncodedCanvas();

      final apiUrl = Uri.parse('http://192.168.1.84:7860/sdapi/v1/img2img');

      final Map<String, String> headers = {
        'Content-Type': 'application/json',
      };

      final width = 512 * imageSizeRatio;

      final Map<String, dynamic> requestBody = {
        "prompt": text.value,
        "init_images": [encodedCanvas],
        "denoising_strength": 0.6,
        "negative_prompt": "",
        "batch_size": 1,
        "steps": 20,
        "width": width,
        "height": 512,
        "cfg_scale": 7,
        "alwayson_scripts": {
          "controlnet": {
            "args": [
              {
                "input_image": encodedCanvas,
                "module": "canny",
              }
            ]
          }
        }
      };

      final String requestBodyJson = jsonEncode(requestBody);

      try {
        final response = await http.post(
          apiUrl,
          headers: headers,
          body: requestBodyJson,
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          responseText.value = "success";

          final imageBytes = base64Decode(data['images'][0]);
          backgroundImage.value = await decodeImageFromList(imageBytes);
        } else {
          responseText.value = 'Error: ${response.statusCode}';
        }
      } catch (e) {
        responseText.value = 'Error: $e';
      } finally {
        isLoading.value = false;
      }
    }

    return Container(
      width: 600,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 3,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: textController,
                    onChanged: (value) => text.value = value,
                    maxLines: null,
                    decoration: const InputDecoration(
                      labelText: 'Enter text prompt',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                width: 150,
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () => _txt2img(),
                  child: isLoading.value
                      ? const CircularProgressIndicator()
                      : const Text('txt2img'),
                ),
              ),
              Container(
                width: 150,
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () => _img2img(),
                  child: isLoading.value
                      ? const CircularProgressIndicator()
                      : const Text('img2img'),
                ),
              ),
              Text(responseText.value),
            ],
          ),
        ],
      ),
    );
  }

  Future<String> getEncodedCanvas() async {
    RenderRepaintBoundary boundary = canvasGlobalKey.currentContext
        ?.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List? pngBytes = byteData?.buffer.asUint8List();

    // encode to base64
    return base64Encode(pngBytes ?? []);
  }
}
