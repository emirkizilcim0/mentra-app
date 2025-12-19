// lib/services/diary/diary_repo_save.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mentra_app/services/dairy/dairy_auth.dart';
import 'package:mentra_app/services/dairy/dairy_config.dart';

class DiaryRepoSave {
  static Future<Map<String, dynamic>> save(Map<String, dynamic> entry) async {
    try {
      final uid = DiaryAuth.getUserId();
      final url = '${DiaryConfig.baseUrl}/diaries/save?user_id=$uid';

      final body = json.encode({
        'content': entry['content'],
        'mood': entry['mood'] ?? '',
        'tags': entry['tags'] ?? [],
      });

      final response = await http.post(
        Uri.parse(url),
        headers: DiaryConfig.jsonHeaders,
        body: body,
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        print('Diary saved: ${result['diary_id']}');
        return {...entry, 'id': result['diary_id'].toString()};
      }
      throw Exception('Failed: ${response.statusCode} - ${response.body}');
    } catch (e) {
      print('Error saving diary: $e');
      rethrow;
    }
  }
}
