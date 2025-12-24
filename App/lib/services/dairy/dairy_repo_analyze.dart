// dairy_repo_analyze.dart
import 'dart:convert' as json;
import 'package:http/http.dart' as http;
import 'package:mentra_app/services/dairy/dairy_config.dart';

class DiaryRepoAnalyze {
  static Future<Map<String, dynamic>> analyze({
    required String cType,
    required String sign,
    required String bMap,
    int count = 10,
    String? content,
    List<String>? diaryIds,
    required String userId, // Add this parameter
  }) async {
    try {
      final url = Uri.parse(
        '${DiaryConfig.baseUrl}/analyze/diaries?user_id=$userId',
      );

      final Map<String, dynamic> body = {
        'user_id': userId, // Add user_id to request body
        'character_type': cType,
        'sign': sign,
        'birth_map': bMap,
        'diary_count': count,
      };

      if (content != null) {
        body['diaries'] = [content];
      }

      if (diaryIds != null && diaryIds.isNotEmpty) {
        body['diary_ids'] = diaryIds;
      }

      print('📤 Sending analysis request for user: $userId');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return json.jsonDecode(response.body);
      } else {
        throw Exception(
          'Failed to analyze: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error in analyze: $e');
      rethrow;
    }
  }
}
