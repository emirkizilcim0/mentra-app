// lib/services/diary_service.dart

import 'dart:convert' as json;
import 'package:http/http.dart' as http;
import 'package:mentra_app/services/dairy/dairy_repo_delete.dart';
import 'package:mentra_app/services/dairy/dairy_repo_analyze.dart';
import 'package:mentra_app/services/dairy/dairy_repo_fetch.dart';
import 'package:mentra_app/services/dairy/dairy_repo_health.dart';
import 'package:mentra_app/services/dairy/dairy_repo_history.dart';
import 'package:mentra_app/services/dairy/dairy_repo_save.dart';
import 'package:mentra_app/services/dairy/dairy_repo_single.dart';
import 'package:mentra_app/services/dairy/dairy_repo_stats.dart';
import 'package:mentra_app/services/dairy/dairy_repo_update.dart';
import 'package:mentra_app/pages/chat/logic_data.dart';
import 'dart:math';
import 'package:mentra_app/services/user_service.dart';

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

  // In your DiaryService class
  // In your DiaryService class
  // In your diary_service.dart, update getAnalysisHistory:
  // In your diary_service.dart, update the getAnalysisHistory method:
  static Future<List<Map<String, dynamic>>> getAnalysisHistory({
    int limit = 10,
    String? userId, // Add this parameter
  }) async {
    try {
      // If userId is not provided, try to get it
      String currentUserId;

      if (userId != null && userId.isNotEmpty) {
        currentUserId = userId;
      } else {
        // Fallback to getting it from UserService
        currentUserId = await UserService.getCurrentUserId();
      }

      print('🔍 Fetching analyses for user: $currentUserId');

      final url = Uri.parse(
        'https://mentra-app-b2ei.onrender.com/analyses?user_id=$currentUserId&limit=$limit',
      );

      print('🌐 API URL: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.jsonDecode(response.body);

        print('📊 Received ${data.length} analyses from backend');

        if (data.isNotEmpty) {
          print('📝 First analysis user_id: ${data[0]['user_id']}');
        }

        return data.map((item) {
          if (item is Map<String, dynamic>) {
            return item;
          } else if (item is Map) {
            return Map<String, dynamic>.from(item);
          } else {
            return <String, dynamic>{};
          }
        }).toList();
      } else {
        print('❌ Error fetching analyses: ${response.statusCode}');
        print('   Response body: ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ Exception in getAnalysisHistory: $e');
      return [];
    }
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
