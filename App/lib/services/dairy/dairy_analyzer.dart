// lib/services/diary/diary_analyzer.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mentra_app/services/dairy/dairy_auth.dart';
import 'package:mentra_app/services/dairy/dairy_config.dart';

class DiaryAnalyzer {
  static Future<Map<String, dynamic>> analyze({
    required String charType,
    required String sign,
    required String birthMap,
    int count = 10,
  }) async {
    try {
      final uid = DiaryAuth.getRequiredId();
      final body = json.encode({
        'user_id': uid,
        'character_type': charType,
        'sign': sign,
        'birth_map': birthMap,
        'diary_count': count,
      });

      final response = await DiaryConfig.client.post(
        Uri.parse('${DiaryConfig.baseUrl}/analyze/diaries'),
        headers: DiaryConfig.jsonHeaders,
        body: body,
      );

      if (response.statusCode == 200) return json.decode(response.body);
      throw Exception('Failed: ${response.statusCode} - ${response.body}');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error analyzing: $e');
      }
      rethrow;
    }
  }
}
