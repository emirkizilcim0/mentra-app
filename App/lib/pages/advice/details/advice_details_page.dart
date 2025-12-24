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

  // --- IMPROVED DATE FORMATTING FUNCTION ---
  String _formatDateUS(Map<String, dynamic> item) {
    // Try different date fields in order of priority
    final dynamic rawDate =
        item['formattedDate'] ??
        item['created_at'] ??
        item['date'] ??
        item['analysis_date'] ??
        DateTime.now();

    if (rawDate == null) return 'Date not available';

    try {
      DateTime date;
      if (rawDate is DateTime) {
        date = rawDate;
      } else if (rawDate is String) {
        // Handle different date string formats
        if (rawDate.contains('T')) {
          // ISO format: "2024-01-01T00:00:00Z"
          date = DateTime.parse(rawDate);
        } else if (rawDate.contains('-')) {
          // Simple date format: "2024-01-01"
          date = DateTime.parse(rawDate);
        } else {
          // Try to parse as timestamp
          final timestamp = int.tryParse(rawDate);
          if (timestamp != null) {
            date = DateTime.fromMillisecondsSinceEpoch(timestamp);
          } else {
            // Fallback to current date
            date = DateTime.now();
          }
        }
      } else if (rawDate is int) {
        // Timestamp in milliseconds
        date = DateTime.fromMillisecondsSinceEpoch(rawDate);
      } else {
        // Unknown type, use current date
        date = DateTime.now();
      }

      // Format in US style: "December 20, 2025"
      return DateFormat('d MMMM, yyyy', 'en_US').format(date.toLocal());
    } catch (e) {
      print('Date parsing error: $e for rawDate: $rawDate');
      return 'Date format error';
    }
  }
  // ---------------------------------------------

  // --- GET MOOD WITH FALLBACK ---
  String _getSafeMood() {
    final mood = analysisItem['mood']?.toString() ?? 'Calm';
    // Ensure mood is one of the expected values
    final validMoods = ['Happy', 'Sad', 'Anxious', 'Angry', 'Calm', 'Neutral'];
    if (validMoods.contains(mood)) {
      return mood;
    }

    // If mood is not valid, try to guess from content
    final moodStr = mood.toLowerCase();
    if (moodStr.contains('happy')) return 'Happy';
    if (moodStr.contains('sad')) return 'Sad';
    if (moodStr.contains('anxious') || moodStr.contains('stressed'))
      return 'Anxious';
    if (moodStr.contains('angry')) return 'Angry';
    if (moodStr.contains('calm') || moodStr.contains('peaceful')) return 'Calm';

    return 'Calm'; // Default
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final mood = _getSafeMood();
    final emoji = _getEmojiForMood(mood);
    final moodColor = _getMoodColor(mood);

    // Get formatted date safely
    final formattedDate = _formatDateUS(analysisItem);

    // Get advice text safely
    final normalizedAdvice =
        analysisItem['advice'] ??
        analysisItem['advice_text'] ??
        analysisItem['analysis'] ??
        analysisItem['analysis_data']?['advice'];

    final adviceText = normalizedAdvice?.toString().trim().isNotEmpty == true
        ? normalizedAdvice.toString()
        : 'No advice available.';

    // Get other details safely
    final diariesAnalyzed = analysisItem['diary_id'] != null ? 1 : 0;

    final characterType = analysisItem['character_type'] ?? 'Not specified';
    final sign = analysisItem['sign'] ?? 'Not specified';

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
                  _buildDetailRow(
                    'Character Type',
                    analysisItem['character_type'] ?? 'Not specified',
                    isDark,
                  ),
                  _buildDetailRow(
                    'Zodiac Sign',
                    analysisItem['sign'] ?? 'Not specified',
                    isDark,
                  ),
                  _buildDetailRow(
                    'Advice Status',
                    analysisItem['has_advice'] == true ? 'Seen' : 'Not seen',
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
      case 'confused':
        return Colors.yellow;
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
      case 'confused':
        return '😕';
      case 'neutral':
        return '😐';
      default:
        return '😊';
    }
  }
}
