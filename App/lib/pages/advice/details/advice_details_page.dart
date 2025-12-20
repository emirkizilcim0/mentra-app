// lib/advice_detail_page.dart
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final mood = analysisItem['mood'] ?? 'Calm';
    final emoji = _getEmojiForMood(mood);
    final moodColor = _getMoodColor(mood);

    return Scaffold(
      backgroundColor: AdviceColors.bg(isDark),
      appBar: AppBar(title: const Text('Advice')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
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
                          AdviceUtils.getDate(analysisItem),
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white70 : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Diaries analyzed: ${analysisItem['diaries_analyzed'] ?? 0}',
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

            CompCard(
              isDark: isDark,
              children: [
                CompDate(
                  date: AdviceUtils.getDate(analysisItem),
                  isDark: isDark,
                ),
                const SizedBox(height: 10),
                CompTitle(title: title, isDark: isDark),
                const SizedBox(height: 16),
                CompBody(
                  text: AdviceUtils.getAdvice(analysisItem),
                  isDark: isDark,
                ),
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
                  if (analysisItem['birth_map'] != null)
                    _buildDetailRow(
                      'Birth Map',
                      analysisItem['birth_map'],
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
      default:
        return '😊';
    }
  }
}
