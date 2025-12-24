// dairy_repo_delete.dart
import 'dart:convert' as json;
import 'package:http/http.dart' as http;

class DiaryRepoDelete {
  static Future<void> delete(String id, {required String userId}) async {
    try {
      final url = Uri.parse(
        'https://mentra-app-b2ei.onrender.com/diaries/$id?user_id=$userId',
      );

      print('🗑️ Deleting diary $id for user: $userId');

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to delete: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error deleting diary: $e');
      rethrow;
    }
  }
}
