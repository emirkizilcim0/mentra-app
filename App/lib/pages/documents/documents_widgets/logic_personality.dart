// lib/logic_personality.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'utils.dart';

class PersonalityLogic {
  static Future<String> loadTest() async {
    try {
      final response = await http.get(Uri.parse(AppConstants.personalityUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final questions = data['test']?['questions'] ?? [];
        return "✅ Personality Test Loaded!\n\n"
            "Number of Questions: ${questions.length}\n\n"
            "Sample Questions:\n${AppUtils.getSampleQuestions(questions)}";
      }
      return "❌ Failed to load test: ${response.statusCode}";
    } catch (e) {
      return "❌ Error loading test: $e";
    }
  }
}
