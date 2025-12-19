// lib/services/diary/diary_repo_stats.dart
import 'package:mentra_app/services/dairy/dairy_repo_fetch.dart';
import 'package:mentra_app/services/dairy/dairy_repo_history.dart';

class DiaryRepoStats {
  static Future<Map<String, dynamic>> getStats() async {
    try {
      final diaries = await DiaryRepoFetch.getAll();
      final analyses = await DiaryRepoHistory.getHistory();
      final moodCounts = <String, int>{};

      for (final d in diaries) {
        final m = d['mood']?.toString().toLowerCase() ?? 'unknown';
        moodCounts[m] = (moodCounts[m] ?? 0) + 1;
      }
      return {
        'total_diaries': diaries.length,
        'total_analyses': analyses.length,
        'mood_distribution': moodCounts,
        'last_diary_date': diaries.isNotEmpty ? diaries.first['date'] : null,
        'last_analysis_date': analyses.isNotEmpty
            ? analyses.first['date']
            : null,
      };
    } catch (e) {
      print('❌ Stats error: $e');
      rethrow;
    }
  }
}
