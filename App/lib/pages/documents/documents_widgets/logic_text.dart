// lib/logic_text.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'utils.dart';

class TextLogic {
  static Future<String> process(String text) async {
    try {
      final response = await http.post(
        Uri.parse(AppConstants.baseUrl),
        headers: AppConstants.jsonHeaders,
        body: jsonEncode({'text': text}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return "✅ Text Processed Successfully!\n\n"
            "Status: ${data['status']}\nMessage: ${data['message']}\n"
            "Chunks Created: ${data['data']?['chunks_count'] ?? 'N/A'}\n\n"
            "Preview: ${AppUtils.getPreview(data['data']?['context'])}";
      }
      return "❌ Error: ${response.statusCode}\n${response.body}";
    } catch (e) {
      return "❌ Network Error: $e\n\nPlease check:\n• Internet connection\n• Backend URL\n• CORS settings";
    }
  }
}
