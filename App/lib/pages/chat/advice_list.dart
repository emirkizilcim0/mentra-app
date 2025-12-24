import 'dart:math';
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
    print('📊 AdviceList building with ${analyses.length} items');

    if (analyses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: 64,
              color: isDark ? Colors.white70 : Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No advice yet',
              style: TextStyle(
                fontSize: 18,
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Analyze your diaries to get advice',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white60 : Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: analyses.length,
      itemBuilder: (context, index) {
        final item = analyses[index];

        print('📋 Item $index keys: ${item.keys.toList()}');

        // Get advice text - check multiple possible fields
        final adviceText =
            item['analysis']?.toString() ??
            item['advice']?.toString() ??
            item['content']?.toString() ??
            '';

        // Get title from advice text
        final title = getTitleFromAdvice(adviceText);

        // Get mood and emoji
        final mood = item['mood']?.toString() ?? 'Calm';
        final emoji = _getEmojiForMood(mood);

        // Get date for display
        final date =
            item['formattedDate']?.toString() ??
            item['created_at']?.toString() ??
            item['date']?.toString() ??
            'Recent';

        print('   Title: ${title.substring(0, min(30, title.length))}...');
        print('   Mood: $mood');
        print('   Date: $date');

        return AdviceCard(
          date: date,
          title: title,
          mood: mood,
          emoji: emoji,
          isDark: isDark,
          onTap: () {
            print('👉 Tapping advice $index');
            print('   Passing item with keys: ${item.keys.toList()}');

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AdviceDetailPage(
                  analysisItem: item, // Pass the full item
                  title: title,
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _getEmojiForMood(String mood) {
    final moodLower = mood.toLowerCase();

    if (moodLower.contains('happy')) return '😊';
    if (moodLower.contains('sad')) return '😢';
    if (moodLower.contains('anxious') || moodLower.contains('worried'))
      return '😰';
    if (moodLower.contains('angry') || moodLower.contains('mad')) return '😠';
    if (moodLower.contains('calm') || moodLower.contains('peaceful'))
      return '😌';
    if (moodLower.contains('neutral')) return '😐';
    if (moodLower.contains('confused')) return '😕';

    return '😊'; // Default
  }
}
