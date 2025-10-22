// lib/document_processor_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DocumentProcessorScreen extends StatefulWidget {
  @override
  _DocumentProcessorScreenState createState() =>
      _DocumentProcessorScreenState();
}

class _DocumentProcessorScreenState extends State<DocumentProcessorScreen> {
  String processingResult = "Welcome to Mentra Document Processor!";
  bool isLoading = false;
  TextEditingController textController = TextEditingController();

  // Process text through backend
  Future<void> processText() async {
    if (textController.text.isEmpty) {
      setState(() {
        processingResult = "Please enter some text to process";
      });
      return;
    }

    setState(() {
      isLoading = true;
      processingResult = "Processing your text...";
    });

    try {
      final response = await http.post(
        Uri.parse('https://mentra-app.onrender.com'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': textController.text}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          processingResult =
              "✅ Text Processed Successfully!\n\n"
              "Status: ${data['status']}\n"
              "Message: ${data['message']}\n"
              "Chunks Created: ${data['data']?['chunks_count'] ?? 'N/A'}\n\n"
              "Preview: ${_getPreview(data['data']?['context'])}";
        });
      } else {
        setState(() {
          processingResult =
              "❌ Error: ${response.statusCode}\n${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        processingResult =
            "❌ Network Error: $e\n\nPlease check:\n• Internet connection\n• Backend URL\n• CORS settings";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String _getPreview(Map<String, dynamic>? context) {
    if (context == null || context.isEmpty) return "No content available";
    final firstKey = context.keys.first;
    final content = context[firstKey] ?? "";
    return content.length > 100 ? content.substring(0, 100) + "..." : content;
  }

  // Test backend connection
  Future<void> testBackend() async {
    setState(() {
      isLoading = true;
      processingResult = "Testing backend connection...";
    });

    try {
      final response = await http.get(
        Uri.parse('https://mentra-app.onrender.com'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          processingResult =
              "✅ Backend Connected!\n\n"
              "Message: ${data['message']}\n"
              "Status: ${data['status']}";
        });
      } else {
        setState(() {
          processingResult = "❌ Backend Error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        processingResult = "❌ Cannot reach backend: $e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Get personality test
  Future<void> getPersonalityTest() async {
    setState(() {
      isLoading = true;
      processingResult = "Loading personality test...";
    });

    try {
      final response = await http.get(
        Uri.parse('https://mentra-backend.onrender.com/personality-test'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final questions = data['test']?['questions'] ?? [];
        setState(() {
          processingResult =
              "✅ Personality Test Loaded!\n\n"
              "Number of Questions: ${questions.length}\n\n"
              "Sample Questions:\n${_getSampleQuestions(questions)}";
        });
      } else {
        setState(() {
          processingResult = "❌ Failed to load test: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        processingResult = "❌ Error loading test: $e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String _getSampleQuestions(List<dynamic> questions) {
    if (questions.isEmpty) return "No questions available";
    String sample = "";
    for (int i = 0; i < questions.length && i < 2; i++) {
      sample += "• ${questions[i]['question']}\n";
    }
    return sample;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mentra Document Processor'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Text input
            TextField(
              controller: textController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Enter your text for analysis',
                border: OutlineInputBorder(),
                hintText:
                    'Type or paste your thoughts, diary entry, or any text you want to analyze...',
              ),
            ),
            SizedBox(height: 20),

            // Buttons row
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : processText,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Process Text'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: isLoading ? null : testBackend,
                    child: Text('Test Connection'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),

            // Additional buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isLoading ? null : getPersonalityTest,
                    child: Text('Load Test'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      textController.clear();
                      setState(() {
                        processingResult = "Ready for new input...";
                      });
                    },
                    child: Text('Clear'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Loading indicator
            if (isLoading) LinearProgressIndicator(),
            SizedBox(height: 20),

            // Results display
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade50,
                ),
                child: SingleChildScrollView(
                  child: Text(
                    processingResult,
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
