// lib/services/diary/diary_repo_delete.dart
import 'package:flutter/foundation.dart';
import 'package:mentra_app/services/dairy/dairy_auth.dart';
import 'package:mentra_app/services/dairy/dairy_config.dart';

class DiaryRepoDelete {
  static Future<void> delete(String diaryId) async {
    try {
      final uid = DiaryAuth.getUserId();
      final uri = Uri.parse(
        '${DiaryConfig.baseUrl}/diaries/$diaryId?user_id=$uid',
      );

      final response = await DiaryConfig.client.delete(uri, headers: DiaryConfig.getHeaders);

      if (response.statusCode == 200) {
        if (kDebugMode) {
          debugPrint('✅ Diary deleted: $diaryId');
        }
      } else {
        throw Exception('Failed delete: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error deleting: $e');
      }
      rethrow;
    }
  }
}
