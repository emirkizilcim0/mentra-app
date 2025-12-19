// lib/services/diary/diary_repo_analyze.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mentra_app/services/dairy/dairy_auth.dart';
import 'package:mentra_app/services/dairy/dairy_config.dart';

class DiaryRepoAnalyze {
  static Future<Map<String, dynamic>> analyze({
    required String cType,
    required String sign,
    required String bMap,
    int count = 10,
  }) async {
    try {
      final uid = DiaryAuth.getUserId();
      final body = json.encode({
        'user_id': uid,
        'character_type': cType,
        'sign': sign,
        'birth_map': bMap,
        'diary_count': count,
      });

      final response = await http.post(
        Uri.parse('${DiaryConfig.baseUrl}/analyze/diaries'),
        headers: DiaryConfig.jsonHeaders,
        body: body,
      );

      if (response.statusCode == 200) return json.decode(response.body);
      throw Exception('Failed analyze: ${response.statusCode}');
    } catch (e) {
      print('❌ Error analyzing: $e');
      rethrow;
    }
  }
}
