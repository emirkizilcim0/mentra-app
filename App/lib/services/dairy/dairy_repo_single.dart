// dairy_repo_single.dart
import 'dart:convert' as json;
import 'package:http/http.dart' as http;

class DiaryRepoSingle {
  static Future<Map<String, dynamic>> get(
    String id, {
    required String userId,
  }) async {
    try {
      // First get all diaries and find the specific one
      final allDiariesUrl = Uri.parse(
        'https://mentra-app-b2ei.onrender.com/diaries/$userId?limit=100',
      );

      final response = await http.get(
        allDiariesUrl,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.jsonDecode(response.body);
        final List<dynamic> diaries = data['diaries'];

        // Find the diary with matching ID
        for (var diary in diaries) {
          if (diary['id'].toString() == id) {
            return Map<String, dynamic>.from(diary);
          }
        }

        throw Exception('Diary not found: $id');
      } else {
        throw Exception('Failed to get diary: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error getting diary: $e');
      rethrow;
    }
  }
}
