import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mentra_app/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'advice_colors.dart';
import 'advice_utils.dart';
import 'comp_card.dart';
import 'comp_date.dart';
import 'comp_title.dart';
import 'comp_body.dart';

class AdviceDetailPage extends StatelessWidget {
  final Map<String, dynamic> analysisItem;
  final String title;

  const AdviceDetailPage({
    super.key,
    required this.analysisItem,
    required this.title,
  });

  // --- DEBUG: Print all data keys and values ---
  void _debugPrintAnalysisData(Map<String, dynamic> item) {
    print('🔍 DEBUG - Analysis Item Keys:');
    item.forEach((key, value) {
      print('  "$key": ${value?.toString() ?? "null"}');
    });

    if (item.containsKey('analysis_data')) {
      print('📊 DEBUG - Analysis Data:');
      if (item['analysis_data'] is Map) {
        final analysisData = item['analysis_data'] as Map;
        analysisData.forEach((key, value) {
          print('  "$key": ${value?.toString() ?? "null"}');
        });
      } else {
        print('  analysis_data type: ${item['analysis_data'].runtimeType}');
        print('  analysis_data value: ${item['analysis_data']}');
      }
    }
  }

  // --- FIXED: BETTER DATE FORMATTING ---
  String _formatDateUS(Map<String, dynamic> item) {
    // Print debug info before processing
    _debugPrintAnalysisData(item);

    // Try multiple possible date fields
    dynamic rawDate;

    // Check in priority order
    if (item['created_at'] != null) {
      rawDate = item['created_at'];
    } else if (item['date'] != null) {
      rawDate = item['date'];
    } else if (item['analysis_date'] != null) {
      rawDate = item['analysis_date'];
    } else if (item['formattedDate'] != null) {
      rawDate = item['formattedDate'];
    } else {
      rawDate = DateTime.now();
    }

    try {
      DateTime date;

      if (rawDate is DateTime) {
        date = rawDate;
      } else if (rawDate is String) {
        // Clean the date string
        String dateStr = rawDate.trim();

        // Handle different formats
        if (dateStr.endsWith('Z')) {
          date = DateTime.parse(dateStr);
        } else if (dateStr.contains('T')) {
          // Add Z if missing for ISO format
          if (!dateStr.endsWith('Z')) {
            dateStr = '${dateStr}Z';
          }
          date = DateTime.parse(dateStr);
        } else if (dateStr.contains('-')) {
          // Simple date without time
          date = DateTime.parse(dateStr);
        } else {
          // Try parsing as timestamp
          final timestamp = int.tryParse(dateStr);
          if (timestamp != null) {
            if (timestamp > 1000000000000) {
              // Likely milliseconds
              date = DateTime.fromMillisecondsSinceEpoch(timestamp);
            } else {
              // Likely seconds
              date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
            }
          } else {
            date = DateTime.now();
          }
        }
      } else if (rawDate is int) {
        if (rawDate > 1000000000000) {
          date = DateTime.fromMillisecondsSinceEpoch(rawDate);
        } else {
          date = DateTime.fromMillisecondsSinceEpoch(rawDate * 1000);
        }
      } else {
        date = DateTime.now();
      }

      // Format in US style: "December 20, 2025"
      return DateFormat('MMMM d, yyyy', 'en_US').format(date.toLocal());
    } catch (e) {
      debugPrint('Date parsing error: $e for rawDate: $rawDate');
      return 'Recent';
    }
  }

  // --- FIXED: BETTER MOOD EXTRACTION ---
  String _getSafeMood(Map<String, dynamic> item) {
    String? mood;

    // 1️⃣ MOST IMPORTANT: results[0].mood (real diary mood)
    if (item['results'] is List &&
        item['results'].isNotEmpty &&
        item['results'][0] is Map &&
        item['results'][0]['mood'] != null) {
      mood = item['results'][0]['mood'].toString().trim();
      print('🎭 DEBUG - Using results[0].mood: $mood');
    }
    // 2️⃣ Fallback: analysis_data mood
    else if (item['analysis_data'] is Map &&
        item['analysis_data']['mood'] != null) {
      mood = item['analysis_data']['mood'].toString().trim();
      print('🎭 DEBUG - Using analysis_data.mood: $mood');
    }
    // 3️⃣ LAST fallback: top-level mood (often normalized)
    else if (item['mood'] != null) {
      mood = item['mood'].toString().trim();
      print('🎭 DEBUG - Using top-level mood: $mood');
    }

    return (mood == null || mood.isEmpty) ? 'Calm' : mood;
  }

  // --- FIXED: BETTER ADVICE TEXT EXTRACTION ---
  String _getAdviceText(Map<String, dynamic> item) {
    String? adviceText;

    print('📝 DEBUG - Checking advice fields:');
    print('  advice: ${item['advice']}');
    print('  advice_text: ${item['advice_text']}');
    print('  analysis: ${item['analysis']}');
    print('  results: ${item['results']}');

    // 1️⃣ Direct fields
    if (item['advice'] != null && item['advice'].toString().trim().isNotEmpty) {
      adviceText = item['advice'].toString();
      print('📝 DEBUG - Using item["advice"]');
    }
    // 2️⃣ analysis_data
    else if (item['analysis_data'] is Map &&
        item['analysis_data']['advice'] != null &&
        item['analysis_data']['advice'].toString().trim().isNotEmpty) {
      adviceText = item['analysis_data']['advice'].toString();
      print('📝 DEBUG - Using analysis_data["advice"]');
    }
    // 3️⃣ ✅ FIX: results[0].advice (THIS WAS MISSING)
    else if (item['results'] is List &&
        item['results'].isNotEmpty &&
        item['results'][0] is Map &&
        item['results'][0]['advice'] != null &&
        item['results'][0]['advice'].toString().trim().isNotEmpty) {
      adviceText = item['results'][0]['advice'].toString();
      print('📝 DEBUG - Using results[0]["advice"]');
    }

    // 4️⃣ Fallback
    if (adviceText == null || adviceText.trim().isEmpty) {
      print('⚠️ DEBUG - No advice text found');
      print('  has_advice: ${item['has_advice']}');

      if (item['has_advice'] == false) {
        return 'No analysis was performed for this entry.';
      }
      return 'No specific advice available.';
    }

    print(
      '✅ DEBUG - Found advice: ${adviceText.substring(0, min(60, adviceText.length))}...',
    );

    return adviceText.trim();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    // Use the fixed extraction methods
    final mood = _getSafeMood(analysisItem);
    final emoji = _getEmojiForMood(mood);
    final moodColor = _getMoodColor(mood);
    final formattedDate = _formatDateUS(analysisItem);
    final adviceText = _getAdviceText(analysisItem);

    // Get other details
    final diariesAnalyzed =
        analysisItem['diaries_analyzed'] ??
        analysisItem['analysis_data']?['individual_analyses'] ??
        1;

    final characterType =
        analysisItem['character_type'] ??
        analysisItem['analysis_data']?['character_type'] ??
        'Not specified';

    final sign =
        analysisItem['sign'] ??
        analysisItem['analysis_data']?['sign'] ??
        'Not specified';

    final birthMap =
        analysisItem['birth_map'] ??
        analysisItem['analysis_data']?['birth_map'] ??
        'Not specified';

    return Scaffold(
      backgroundColor: AdviceColors.bg(isDark),
      appBar: AppBar(
        title: Text(title),
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mood indicator at the top
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: moodColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: moodColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: moodColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Text(emoji, style: const TextStyle(fontSize: 32)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Mood: $mood',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: moodColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white70 : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Diaries analyzed: $diariesAnalyzed',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white60 : Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Advice card
            CompCard(
              isDark: isDark,
              children: [
                CompDate(date: formattedDate, isDark: isDark),
                const SizedBox(height: 10),
                CompTitle(title: title, isDark: isDark),
                const SizedBox(height: 16),
                CompBody(text: adviceText, isDark: isDark),
              ],
            ),

            const SizedBox(height: 20),

            // Analysis details section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Analysis Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow('Character Type', characterType, isDark),
                  _buildDetailRow('Zodiac Sign', sign, isDark),
                  _buildDetailRow('Birth Map', birthMap, isDark),
                  _buildDetailRow(
                    'Analysis Type',
                    analysisItem['analysis_type'] ?? 'Diary Analysis',
                    isDark,
                  ),
                  _buildDetailRow(
                    'Status',
                    analysisItem['has_advice'] == true
                        ? 'Has Advice'
                        : 'No Advice',
                    isDark,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return Colors.green;
      case 'sad':
        return Colors.blue;
      case 'anxious':
        return Colors.orange;
      case 'angry':
        return Colors.red;
      case 'calm':
        return Colors.blueAccent;
      case 'neutral':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getEmojiForMood(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return '😊';
      case 'sad':
        return '😢';
      case 'anxious':
        return '😰';
      case 'angry':
        return '😠';
      case 'calm':
        return '😌';
      case 'neutral':
        return '😐';
      default:
        return '😊';
    }
  }
}
