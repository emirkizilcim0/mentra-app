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

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Debug: Print raw response
        print('📦 Raw API response received');
        print('📊 Response body length: ${response.body.length}');

        // Pretty print the response for debugging
        final prettyJson = JsonEncoder.withIndent('  ').convert(data);
        print('📄 Response data:\n$prettyJson');

        final List<dynamic> list = data['analyses'] ?? [];
        print('📊 Found ${list.length} analyses');

        // Map each analysis item with mood extraction
        return list.map((e) {
          print('🔍 Processing analysis item:');
          print('   Raw item keys: ${e.keys.toList()}');
          print('   Raw mood value: "${e['mood']}"');

          final mapped = DiaryMapper.mapAnalysis(e);
          print('   Mapped mood: "${mapped['mood']}"');

          // Extract mood from the advice text if not already present
          if (mapped['mood'] == null ||
              mapped['mood'] == '' ||
              mapped['mood'] == 'Calm') {
            print('   ⚠️ Mood missing or default, extracting from advice...');
            final extractedMood = _extractMoodFromAdvice(
              mapped['advice'] ?? '',
            );
            mapped['mood'] = extractedMood;
            print('   Extracted mood: $extractedMood');
          }

          // Add formatted date if not present
          if (mapped['date'] != null && mapped['formattedDate'] == null) {
            mapped['formattedDate'] = _formatDate(mapped['date']!);
          }

          print('   ✅ Final mood: ${mapped['mood']}');

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
