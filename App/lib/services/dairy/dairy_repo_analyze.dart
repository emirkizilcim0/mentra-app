// lib/services/dairy/dairy_repo_analyze.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class DiaryRepoAnalyze {
  static const String baseUrl =
      'https://mentra-app.onrender.com'; // UPDATE THIS

  static Future<Map<String, dynamic>> analyze({
    required String cType,
    required String sign,
    required String bMap,
    required int count,
    String? content,
    List<String>? diaryIds,
    required String userId, // ADD THIS PARAMETER
    List<Map<String, dynamic>>? userDiaries, // ADD THIS PARAMETER
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/analyze/diaries'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId, // CRITICAL: Backend requires this
          'character_type': cType,
          'sign': sign,
          'birth_map': bMap,
          'diary_count': count, // Should be 1 for specific diary analysis
          'specific_content': content,
          'specific_ids': diaryIds,
          'diaries': userDiaries != null
              ? userDiaries.map((d) => d['content'] ?? d['text'] ?? '').toList()
              : null, // Send diary content directly
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to analyze: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
