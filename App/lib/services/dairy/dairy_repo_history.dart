// lib/services/diary/diary_repo_history.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mentra_app/services/dairy/dairy_auth.dart';
import 'package:mentra_app/services/dairy/dairy_config.dart';
import 'package:mentra_app/services/dairy/dairy_mapper.dart';

class DiaryRepoHistory {
  static Future<List<Map<String, dynamic>>> getHistory({int limit = 10}) async {
    try {
      final uid = DiaryAuth.getUserId();
      final uri = Uri.parse(
        '${DiaryConfig.baseUrl}/analysis/history/$uid?limit=$limit',
      );

      print('🔍 Fetching history from: $uri');

      final response = await http.get(uri, headers: DiaryConfig.getHeaders);

      print('📡 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('📊 Parsed data type: ${data.runtimeType}');

        final List<dynamic> list = data['analyses'] ?? [];
        print('📄 Found ${list.length} analyses');

        // Debug first item
        if (list.isNotEmpty) {
          print('🔍 First analysis item: ${jsonEncode(list[0])}');
          print('🔍 First analysis mood: ${list[0]['mood']}');
        }

        return list.map((e) {
          final mapped = DiaryMapper.mapAnalysis(e);
          print('🗺️ Mapped analysis: ${jsonEncode(mapped)}');
          return mapped;
        }).toList();
      }
      throw Exception('Failed history: ${response.statusCode}');
    } catch (e) {
      print('❌ Error getting history: $e');
      rethrow;
    }
  }

  // Helper to extract mood from advice text
  static String _extractMoodFromAdvice(String advice) {
    final adviceLower = advice.toLowerCase();

    // Check for mood indicators in the advice text
    if (adviceLower.contains('happy') ||
        adviceLower.contains('joy') ||
        adviceLower.contains('excited') ||
        adviceLower.contains('great') ||
        adviceLower.contains('wonderful') ||
        adviceLower.contains('positive')) {
      return 'Happy';
    } else if (adviceLower.contains('sad') ||
        adviceLower.contains('depressed') ||
        adviceLower.contains('down') ||
        adviceLower.contains('disappointed') ||
        adviceLower.contains('unhappy')) {
      return 'Sad';
    } else if (adviceLower.contains('anxious') ||
        adviceLower.contains('anxiety') ||
        adviceLower.contains('stress') ||
        adviceLower.contains('worried') ||
        adviceLower.contains('nervous')) {
      return 'Anxious';
    } else if (adviceLower.contains('angry') ||
        adviceLower.contains('anger') ||
        adviceLower.contains('frustrated') ||
        adviceLower.contains('irritated') ||
        adviceLower.contains('upset')) {
      return 'Angry';
    } else if (adviceLower.contains('calm') ||
        adviceLower.contains('peaceful') ||
        adviceLower.contains('relaxed') ||
        adviceLower.contains('serene') ||
        adviceLower.contains('tranquil')) {
      return 'Calm';
    } else if (adviceLower.contains('confused') ||
        adviceLower.contains('uncertain') ||
        adviceLower.contains('unsure') ||
        adviceLower.contains('indecisive')) {
      return 'Confused';
    }

    // Default mood
    return 'Calm';
  }

  // Helper to format date
  static String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}
