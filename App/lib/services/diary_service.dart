import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class DiaryService {
  static const String baseUrl = 'https://mentra-app.onrender.com';
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  static String? get _userId => _auth.currentUser?.uid;

  // Save a new diary entry to FastAPI backend
  // Save a new diary entry to FastAPI backend - FIXED VERSION
  static Future<Map<String, dynamic>> saveDiaryEntry(
    Map<String, dynamic> entry,
  ) async {
    try {
      if (_userId == null) {
        throw Exception('User not authenticated');
      }

      // FIX: Send user_id as query parameter in the URL
      final response = await http.post(
        Uri.parse('$baseUrl/diaries/save?user_id=$_userId'), // ✅ user_id in URL
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'content': entry['content'],
          'mood': entry['mood'] ?? '',
          'tags': entry['tags'] ?? [],
        }),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        print('Diary saved to backend: ${result['diary_id']}');
        return {...entry, 'id': result['diary_id'].toString()};
      } else {
        throw Exception(
          'Failed to save diary: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error saving diary to backend: $e');
      rethrow;
    }
  }

  // Get diary entries from FastAPI backend
  static Future<List<Map<String, dynamic>>> getDiaryEntries() async {
    try {
      if (_userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/diaries/$_userId?limit=50'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> diaries = data['diaries'];

        // Convert backend format to your app's expected format
        return diaries.map((diary) {
          return {
            'id': diary['id'].toString(),
            'title': _generateTitleFromContent(diary['content']),
            'content': diary['content'],
            'date': diary['date'],
            'formattedDate': _formatDateForDisplay(diary['date']),
            'mood': diary['mood'] ?? '',
            'tags': List<String>.from(diary['tags'] ?? []),
          };
        }).toList();
      } else {
        throw Exception(
          'Failed to fetch diaries: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error getting diaries from backend: $e');
      rethrow;
    }
  }

  // Analyze diaries with AI psychologist
  static Future<Map<String, dynamic>> analyzeDiaries({
    required String characterType,
    required String sign,
    required String birthMap,
    int diaryCount = 10,
  }) async {
    try {
      if (_userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/analyze/diaries'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': _userId,
          'character_type': characterType,
          'sign': sign,
          'birth_map': birthMap,
          'diary_count': diaryCount,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Failed to analyze diaries: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error analyzing diaries: $e');
      rethrow;
    }
  }

  // Get analysis history
  static Future<List<Map<String, dynamic>>> getAnalysisHistory({
    int limit = 10,
  }) async {
    try {
      if (_userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/analysis/history/$_userId?limit=$limit'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> analyses = data['analyses'];

        return analyses.map((analysis) {
          return {
            'id': analysis['id'].toString(),
            'type': analysis['type'],
            'advice': analysis['advice'],
            'diaries_analyzed': analysis['diaries_analyzed'],
            'date': analysis['date'],
            'formattedDate': _formatDateForDisplay(analysis['date']),
          };
        }).toList();
      } else {
        throw Exception(
          'Failed to fetch analysis history: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Error getting analysis history: $e');
      rethrow;
    }
  }

  // Delete diary entry
  static Future<void> deleteDiaryEntry(String diaryId) async {
    try {
      if (_userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/diaries/$diaryId?user_id=$_userId'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('✅ Diary deleted successfully: $diaryId');
      } else {
        throw Exception(
          'Failed to delete diary: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error deleting diary: $e');
      rethrow;
    }
  }

  // Get specific diary entry
  static Future<Map<String, dynamic>> getDiaryEntry(String diaryId) async {
    try {
      if (_userId == null) {
        throw Exception('User not authenticated');
      }

      // First get all diaries and find the specific one
      final diaries = await getDiaryEntries();
      final diary = diaries.firstWhere(
        (diary) => diary['id'] == diaryId,
        orElse: () => throw Exception('Diary not found'),
      );

      return diary;
    } catch (e) {
      print('❌ Error getting diary entry: $e');
      rethrow;
    }
  }

  // Update diary entry
  static Future<Map<String, dynamic>> updateDiaryEntry(
    String diaryId,
    Map<String, dynamic> updates,
  ) async {
    try {
      if (_userId == null) {
        throw Exception('User not authenticated');
      }

      // Note: You'll need to implement an update endpoint in your backend
      // For now, we'll delete and create a new one, or you can implement properly
      await deleteDiaryEntry(diaryId);
      final newEntry = await saveDiaryEntry(updates);

      return newEntry;
    } catch (e) {
      print('❌ Error updating diary entry: $e');
      rethrow;
    }
  }

  // Helper methods
  static String _generateTitleFromContent(String content) {
    if (content.isEmpty) return 'Untitled Diary';
    final lines = content.split('\n');
    final firstLine = lines.first.trim();
    if (firstLine.length <= 30) return firstLine;
    return '${firstLine.substring(0, 30)}...';
  }

  static String _formatDateForDisplay(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${_getWeekday(date.weekday)}, ${date.day} ${_getMonth(date.month)} ${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  static String _getWeekday(int weekday) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[weekday - 1];
  }

  static String _getMonth(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  // Utility method to check backend health
  static Future<bool> checkBackendHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/'),
        headers: {'Accept': 'application/json'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Backend health check failed: $e');
      return false;
    }
  }

  // Get user statistics
  static Future<Map<String, dynamic>> getUserStatistics() async {
    try {
      if (_userId == null) {
        throw Exception('User not authenticated');
      }

      final diaries = await getDiaryEntries();
      final analyses = await getAnalysisHistory();

      // Calculate mood statistics
      final moodCounts = <String, int>{};
      for (final diary in diaries) {
        final mood = diary['mood']?.toString().toLowerCase() ?? 'unknown';
        moodCounts[mood] = (moodCounts[mood] ?? 0) + 1;
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
      print('❌ Error getting user statistics: $e');
      rethrow;
    }
  }
}
