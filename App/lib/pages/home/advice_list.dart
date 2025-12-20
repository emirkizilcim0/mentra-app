import 'package:flutter/material.dart';
import 'package:mentra_app/pages/advice/details/advice_details_page.dart';
import 'package:mentra_app/pages/chat/advice_card.dart';
import 'package:mentra_app/pages/chat/advice_utils.dart';

import 'sentiment_calc.dart';

class AdviceList extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final bool isDark;

  const AdviceList({super.key, required this.items, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final advice = item['advice'] ?? '';
        final title = getTitleFromAdvice(advice);
        final mood = item['mood'] ?? 'Calm'; // Get mood from item
        final percent = estimateHappinessPercent(advice);

        // Use mood-based emoji if available, otherwise fallback to sentiment
        final emoji = mood != 'Calm'
            ? _getEmojiForMood(mood)
            : getEmojiFor(percent);

        return AdviceCard(
          date: item['formattedDate'] ?? item['date'] ?? '',
          title: title,
          mood: mood, // Pass mood to card
          emoji: emoji,
          isDark: isDark,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  AdviceDetailPage(analysisItem: item, title: title),
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
