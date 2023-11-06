import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PromptBox extends StatefulWidget {
  const PromptBox({super.key});

  @override
  _PromptBoxState createState() => _PromptBoxState();
}

class _PromptBoxState extends State<PromptBox> {
  String text = '';
  bool isLoading = false;
  String responseText = '';

  // Define a TextEditingController for the TextField
  TextEditingController textController = TextEditingController();

  void _sendText() async {
    setState(() {
      isLoading = true;
    });

    // Your API endpoint URL
    final apiUrl = Uri.parse('https://your-api-endpoint.com');

    // Define the request headers and body as needed
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    final Map<String, dynamic> requestBody = {
      'text': textController.text,
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
        setState(() {
          responseText = data['response']; // Replace with your response field
        });
      } else {
        // Handle API error
        responseText = 'Error: ${response.statusCode}';
      }
    } catch (e) {
      // Handle network or other errors
      responseText = 'Error: $e';
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                padding:
                    const EdgeInsets.all(16), // Add padding to the TextField
                child: TextField(
                  controller: textController,
                  onChanged: (value) {
                    setState(() {
                      text = value;
                    });
                  },
                  maxLines: null, // Allow multiple lines of text
                  decoration: const InputDecoration(
                    labelText: 'Enter text prompt',
                    border: InputBorder.none, // Remove the underline
                  ),
                ),
              ),
              const Spacer()
            ],
          )),
          Container(
            width: 150, // Set the fixed width for the button
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _sendText,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Generate'),
            ),
          ),
        ],
      ),
    );
  }
}
