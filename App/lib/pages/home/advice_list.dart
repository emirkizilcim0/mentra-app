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
        final percent = estimateHappinessPercent(advice);

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
