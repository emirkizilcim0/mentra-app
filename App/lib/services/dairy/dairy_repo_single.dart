// lib/services/diary/diary_repo_single.dart
import 'package:mentra_app/services/dairy/dairy_repo_fetch.dart';
import 'package:flutter/foundation.dart';

class DiaryRepoSingle {
  static Future<Map<String, dynamic>> get(String diaryId) async {
    try {
      // Önce hepsini çekip sonra filtreliyoruz
      final diaries = await DiaryRepoFetch.getAll();

      return diaries.firstWhere(
        (diary) => diary['id'] == diaryId,
        orElse: () => throw Exception('Diary not found'),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting diary entry: $e');
      }
      rethrow;
    }
  }
}
