// lib/services/diary_service.dart
import 'package:http/http.dart' as DiaryRepoDelete;
import 'package:mentra_app/services/dairy/dairy_repo_analyze.dart';
import 'package:mentra_app/services/dairy/dairy_repo_fetch.dart';
import 'package:mentra_app/services/dairy/dairy_repo_health.dart';
import 'package:mentra_app/services/dairy/dairy_repo_history.dart';
import 'package:mentra_app/services/dairy/dairy_repo_save.dart';
import 'package:mentra_app/services/dairy/dairy_repo_single.dart';
import 'package:mentra_app/services/dairy/dairy_repo_stats.dart';
import 'package:mentra_app/services/dairy/dairy_repo_update.dart';

class DiaryService {
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

  static Future<Map<String, dynamic>> analyzeDiaries({
    required String characterType,
    required String sign,
    required String birthMap,
    int diaryCount = 10,
  }) => DiaryRepoAnalyze.analyze(
    cType: characterType,
    sign: sign,
    bMap: birthMap,
    count: diaryCount,
  );

  static Future<List<Map<String, dynamic>>> getAnalysisHistory({
    int limit = 10,
  }) => DiaryRepoHistory.getHistory(limit: limit);

  static Future<Map<String, dynamic>> getUserStatistics() =>
      DiaryRepoStats.getStats();

  static Future<bool> checkBackendHealth() => DiaryRepoHealth.check();
}
