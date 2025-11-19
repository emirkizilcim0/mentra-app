import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class DiaryService {
  static const String baseUrl =
      'https://mentra-app.onrender.com'; // Replace with your Render URL
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  static String? get _userId => _auth.currentUser?.uid;

  // Save a new diary entry to FastAPI backend
  static Future<Map<String, dynamic>> saveDiaryEntry(
    Map<String, dynamic> entry,
  ) async {
    try {
      if (_userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/diaries/save?user_id=$_userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'content': entry['content'],
          'mood': entry['mood'] ?? '',
          'tags': entry['tags'] ?? [],
        }),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        print('✅ Diary saved to backend: ${result['diary_id']}');
        return entry; // Return the original entry with any updates
      } else {
        throw Exception(
          'Failed to save diary: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error saving diary to backend: $e');
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
        throw Exception('Failed to fetch diaries: ${response.statusCode}');
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
        throw Exception('Failed to analyze diaries: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error analyzing diaries: $e');
      rethrow;
    }
  }

  // Delete diary entry
  static Future<void> deleteDiaryEntry(String diaryId) async {
    try {
      // Note: You'll need to add a DELETE endpoint to your FastAPI backend
      final response = await http.delete(
        Uri.parse('$baseUrl/diaries/$diaryId'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete diary: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error deleting diary: $e');
      rethrow;
    }
  }

  // Helper methods
  static String _generateTitleFromContent(String content) {
    if (content.length <= 30) return content;
    return '${content.substring(0, 30)}...';
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
}
