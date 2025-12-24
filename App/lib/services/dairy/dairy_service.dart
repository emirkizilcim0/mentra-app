// lib/services/dairy/dairy_service.dart
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
import 'package:mentra_app/services/dairy/dairy_auth.dart';

class DiaryService {
  static List<Map<String, dynamic>>? _diariesCache;
  static DateTime? _diariesCacheAt;
  static List<Map<String, dynamic>>? _historyCache;
  static DateTime? _historyCacheAt;
  static const Duration _ttl = Duration(seconds: 30);

  // Helper to get Firebase user ID
  static String _getUserId() {
    return DiaryAuth.getUserId();
  }

  static Future<Map<String, dynamic>> saveDiaryEntry(
    Map<String, dynamic> entry,
  ) async {
    final userId = _getUserId();
    print('💾 Saving diary for user: $userId');
    final res = await DiaryRepoSave.save(entry, userId: userId);
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

    final userId = _getUserId();
    print('📋 Getting diaries for user: $userId');

    final list = await DiaryRepoFetch.getAll(userId: userId);
    _diariesCache = list;
    _diariesCacheAt = now;
    return list;
  }

  static Future<Map<String, dynamic>> getDiaryEntry(String id) {
    final userId = _getUserId();
    return DiaryRepoSingle.get(id, userId: userId);
  }

  static Future<Map<String, dynamic>> updateDiaryEntry(
    String id,
    Map<String, dynamic> updates,
  ) async {
    final userId = _getUserId();
    final res = await DiaryRepoUpdate.update(id, updates, userId: userId);
    _diariesCache = null;
    _historyCache = null;
    return res;
  }

  static Future<void> deleteDiaryEntry(String id) async {
    final userId = _getUserId();
    await DiaryRepoDelete.delete(id, userId: userId);
    _diariesCache = null;
    _historyCache = null;
  }

  static Future<Map<String, dynamic>> analyzeDiaries({
    required String characterType,
    required String sign,
    required String birthMap,
    int diaryCount = 10,
    String? specificContent,
    List<String>? specificIds,
  }) async {
    final userId = _getUserId();
    print('🔍 Analyzing diaries for user: $userId');

    return await DiaryRepoAnalyze.analyze(
      cType: characterType,
      sign: sign,
      bMap: birthMap,
      count: diaryCount,
      content: specificContent,
      diaryIds: specificIds,
      userId: userId,
    );
  }

  static Future<List<Map<String, dynamic>>> getAnalysisHistory({
    int limit = 50,
  }) async {
    try {
      final userId = _getUserId();
      print('🔍 Fetching analyses for user: $userId');

      final response = await http.get(
        Uri.parse(
          'https://mentra-app-b2ei.onrender.com/analysis/history/$userId?limit=$limit',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.jsonDecode(response.body);

        if (data.containsKey('analyses')) {
          final List<dynamic> analyses = data['analyses'];
          print('📊 Received ${analyses.length} analyses from backend');

          return analyses.map((item) {
            if (item is Map<String, dynamic>) {
              return item;
            } else if (item is Map) {
              return Map<String, dynamic>.from(item);
            } else {
              return <String, dynamic>{};
            }
          }).toList();
        } else {
          print('❌ No "analyses" key in response');
          return [];
        }
      } else if (response.statusCode == 404) {
        print('📭 No analyses found for user $userId');
        return [];
      } else {
        print('❌ Error fetching analyses: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Exception in getAnalysisHistory: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> saveAnalysis({
    required int diaryId,
    required String advice,
    required String analysis,
    required String characterType,
    required String sign,
    String mood = 'Neutral',
    String moodSource = 'ai_detected',
    bool hasAdvice = true,
    bool seen = false,
  }) async {
    final userId = _getUserId();
    print('💾 Saving analysis for user: $userId, diary: $diaryId');

    final response = await http.post(
      Uri.parse(
        'https://mentra-app-b2ei.onrender.com/analyses?user_id=$userId',
      ),
      headers: {'Content-Type': 'application/json'},
      body: json.jsonEncode({
        'diary_id': diaryId,
        'advice': advice,
        'analysis': analysis,
        'mood': mood,
        'mood_source': moodSource,
        'character_type': characterType,
        'sign': sign,
        'has_advice': hasAdvice,
        'seen': seen,
      }),
    );

    if (response.statusCode == 200) {
      final result = json.jsonDecode(response.body);
      _historyCache = null;
      return result;
    } else {
      throw Exception('Failed to save analysis: ${response.statusCode}');
    }
  }

  static Future<void> markAnalysisAsSeen(int analysisId) async {
    final userId = _getUserId();

    final response = await http.patch(
      Uri.parse(
        'https://mentra-app-b2ei.onrender.com/analyses/$analysisId?user_id=$userId&seen=true',
      ),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      print('⚠️ Failed to mark analysis as seen: ${response.statusCode}');
    }
  }

  static Future<bool> checkBackendHealth() async {
    try {
      final response = await http.get(
        Uri.parse('https://mentra-app-b2ei.onrender.com/health'),
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> getUserStatistics() {
    final userId = _getUserId();
    return DiaryRepoStats.getStats(userId);
  }
}
