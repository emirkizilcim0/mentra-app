// dairy_repo_save.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mentra_app/services/dairy/dairy_config.dart';

class DiaryRepoSave {
  static Future<Map<String, dynamic>> save(
    Map<String, dynamic> entry, {
    required String userId,
  }) async {
    try {
      final url = '${DiaryConfig.baseUrl}/diaries/save?user_id=$userId';

      final response = await DiaryConfig.client.post(
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
      if (kDebugMode) {
        debugPrint('Error saving diary: $e');
      }
      rethrow;
    }
  }
}
