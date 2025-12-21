// lib/services/diary_service.dart

import 'package:mentra_app/services/dairy/dairy_repo_delete.dart';
import 'package:mentra_app/services/dairy/dairy_repo_analyze.dart';
import 'package:mentra_app/services/dairy/dairy_repo_fetch.dart';
import 'package:mentra_app/services/dairy/dairy_repo_health.dart';
import 'package:mentra_app/services/dairy/dairy_repo_history.dart';
import 'package:mentra_app/services/dairy/dairy_repo_save.dart';
import 'package:mentra_app/services/dairy/dairy_repo_single.dart';
import 'package:mentra_app/services/dairy/dairy_repo_stats.dart';
import 'package:mentra_app/services/dairy/dairy_repo_update.dart';

class DiaryService {
  static List<Map<String, dynamic>>? _diariesCache;
  static DateTime? _diariesCacheAt;
  static List<Map<String, dynamic>>? _historyCache;
  static DateTime? _historyCacheAt;
  static const Duration _ttl = Duration(seconds: 45);

  static Future<Map<String, dynamic>> saveDiaryEntry(
    Map<String, dynamic> entry,
  ) async {
    final res = await DiaryRepoSave.save(entry);
    _diariesCache = null;
    _historyCache = null;
    return res;
  }

  static Future<List<Map<String, dynamic>>> getDiaryEntries() async {
    final now = DateTime.now();
    if (_diariesCache != null &&
        _diariesCacheAt != null &&
        now.difference(_diariesCacheAt!) < _ttl) {
      return _diariesCache!;
    }
    final list = await DiaryRepoFetch.getAll();
    _diariesCache = list;
    _diariesCacheAt = now;
    return list;
  }

  static Future<Map<String, dynamic>> getDiaryEntry(String id) =>
      DiaryRepoSingle.get(id);

  static Future<Map<String, dynamic>> updateDiaryEntry(
    String id,
    Map<String, dynamic> updates,
  ) async {
    final res = await DiaryRepoUpdate.update(id, updates);
    _diariesCache = null;
    _historyCache = null;
    return res;
  }

  static Future<void> deleteDiaryEntry(String id) async {
    await DiaryRepoDelete.delete(id);
    _diariesCache = null;
    _historyCache = null;
  }

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
    return await DiaryRepoAnalyze.analyze(
      cType: characterType,
      sign: sign,
      bMap: birthMap,
      count: diaryCount,
      content: specificContent,
      diaryIds: specificIds,
    );
  }
  // -------------------------

  static Future<List<Map<String, dynamic>>> getAnalysisHistory({
    int limit = 10,
  }) async {
    final now = DateTime.now();
    if (limit == 10 &&
        _historyCache != null &&
        _historyCacheAt != null &&
        now.difference(_historyCacheAt!) < _ttl) {
      return _historyCache!;
    }
    final list = await DiaryRepoHistory.getHistory(limit: limit);
    if (limit == 10) {
      _historyCache = list;
      _historyCacheAt = now;
    }
    return list;
  }

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
