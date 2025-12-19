// lib/services/diary/diary_saver.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mentra_app/services/dairy/dairy_auth.dart';
import 'package:mentra_app/services/dairy/dairy_config.dart';

class DiarySaver {
  static Future<Map<String, dynamic>> save(Map<String, dynamic> entry) async {
    try {
      final uid = DiaryAuth.getRequiredId();
      final url = '${DiaryConfig.baseUrl}/diaries/save?user_id=$uid';

      final response = await http.post(
        Uri.parse(url),
        headers: DiaryConfig.jsonHeaders,
        body: json.encode({
          'content': entry['content'],
          'mood': entry['mood'] ?? '',
          'tags': entry['tags'] ?? [],
        }),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return {...entry, 'id': result['diary_id'].toString()};
      }
      throw Exception('Failed: ${response.statusCode} - ${response.body}');
    } catch (e) {
      print('Error saving diary: $e');
      rethrow;
    }
  }
}
