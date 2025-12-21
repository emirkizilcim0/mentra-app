// lib/services/diary_service.dart

import 'package:http/http.dart' as DiaryRepoDelete;
import 'dart:convert'; // ADD THIS
import 'package:mentra_app/services/dairy/dairy_repo_analyze.dart';
import 'package:mentra_app/services/dairy/dairy_repo_fetch.dart';
import 'package:mentra_app/services/dairy/dairy_repo_health.dart';
import 'package:mentra_app/services/dairy/dairy_repo_history.dart';
import 'package:mentra_app/services/dairy/dairy_repo_save.dart';
import 'package:mentra_app/services/dairy/dairy_repo_single.dart';
import 'package:mentra_app/services/dairy/dairy_repo_stats.dart';
import 'package:mentra_app/services/dairy/dairy_repo_update.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ADD THIS for user_id

class DiaryService {
  // Helper method to get user_id
  static Future<String> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id') ?? 'unknown_user';
  }

  static Future<Map<String, dynamic>> saveDiaryEntry(
    Map<String, dynamic> entry,
  ) => DiaryRepoSave.save(entry);

  static Future<List<Map<String, dynamic>>> getDiaryEntries() =>
      DiaryRepoFetch.getAll();

  static Future<Map<String, dynamic>> getDiaryEntry(String id) =>
      DiaryRepoSingle.get(id);

  static Future<Map<String, dynamic>> updateDiaryEntry(
    String id,
    Map<String, dynamic> updates,
  ) => DiaryRepoUpdate.update(id, updates);

  static Future<void> deleteDiaryEntry(String id) =>
      DiaryRepoDelete.delete(id as Uri);

  // --- COMPLETELY UPDATED analyzeDiaries METHOD ---
  static Future<Map<String, dynamic>> analyzeDiaries({
    required String characterType,
    required String sign,
    required String birthMap,
    int diaryCount = 10,
    String? specificContent,
    List<String>? specificIds,
    List<Map<String, dynamic>>?
    userDiaries, // NEW: For sending diary content directly
  }) async {
    // Get user ID first
    final userId = await _getUserId();

    return await DiaryRepoAnalyze.analyze(
      cType: characterType,
      sign: sign,
      bMap: birthMap,
      count: diaryCount,
      content: specificContent,
      diaryIds: specificIds,
      userId: userId, // ADD THIS
      userDiaries: userDiaries, // ADD THIS
    );
  }
  // -------------------------

  static Future<List<Map<String, dynamic>>> getAnalysisHistory({
    int limit = 10,
  }) => DiaryRepoHistory.getHistory(limit: limit);

  static Future<Map<String, dynamic>> getUserStatistics() =>
      DiaryRepoStats.getStats();

  static Future<bool> checkBackendHealth() => DiaryRepoHealth.check();

  static Future<Map<String, dynamic>?> getAdviceByDiaryId(String id) async {
    try {
      final diary = await getDiaryEntry(id);
      if (diary['advice'] != null || diary['analysis'] != null) {
        return diary;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
