import 'package:flutter/material.dart';
import 'package:mentra_app/pages/advice/details/advice_details_page.dart';
import 'advice_card.dart';
import 'advice_utils.dart';
import 'sentiment_logic.dart';

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
        final percent = estimateHappinessPercent(adviceText);

        return AdviceCard(
          date: item['formattedDate'] ?? item['date'] ?? '',
          title: title,
          emoji: getEmojiFor(percent),
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
}
