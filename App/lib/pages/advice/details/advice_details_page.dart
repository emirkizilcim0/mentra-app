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
    return Scaffold(
      backgroundColor: AdviceColors.bg(isDark),
      appBar: AppBar(title: const Text('Advice')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: CompCard(
          isDark: isDark,
          children: [
            CompDate(date: AdviceUtils.getDate(analysisItem), isDark: isDark),
            const SizedBox(height: 10),
            CompTitle(title: title, isDark: isDark),
            const SizedBox(height: 16),
            CompBody(text: AdviceUtils.getAdvice(analysisItem), isDark: isDark),
          ],
        ),
      ),
    );
  }
}
