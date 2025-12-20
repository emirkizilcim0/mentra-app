import 'package:flutter/material.dart';
import 'package:mentra_app/pages/advice/details/advice_details_page.dart';
import 'advice_card.dart';
import 'advice_utils.dart';

class AdviceList extends StatelessWidget {
  final List<Map<String, dynamic>> analyses;
  final bool isDark;

  const AdviceList({super.key, required this.analyses, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: analyses.length,
      itemBuilder: (context, index) {
        final item = analyses[index];
        final adviceText = item['advice'] ?? '';
        final title = getTitleFromAdvice(adviceText);
        final mood = item['mood'] ?? 'Calm';

        // Get emoji based on mood
        final emoji = _getEmojiForMood(mood);

        return AdviceCard(
          date: item['formattedDate'] ?? item['date'] ?? '',
          title: title,
          mood: mood,
          emoji: emoji,
          isDark: isDark,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AdviceDetailPage(
                analysisItem: item,
                title: title,
                // Remove mood parameter if AdviceDetailPage doesn't accept it
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper function to get emoji based on mood
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
