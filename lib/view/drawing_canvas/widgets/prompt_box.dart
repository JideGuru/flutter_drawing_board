import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PromptBox extends StatefulWidget {
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
    return Column(
      children: <Widget>[
        TextField(
          controller: textController,
          onChanged: (value) {
            setState(() {
              text = value;
            });
          },
          decoration: InputDecoration(labelText: 'Enter text'),
        ),
        SizedBox(height: 20),
        Row(
          children: <Widget>[
            ElevatedButton(
              onPressed: _sendText,
              child: Text('Generate'),
            ),
            if (isLoading) CircularProgressIndicator(),
          ],
        ),
        SizedBox(height: 20),
        Text(responseText),
      ],
    );
  }
}
