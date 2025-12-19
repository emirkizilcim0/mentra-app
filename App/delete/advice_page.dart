/*
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mentra_app/pages/advice/details/advice_details_page.dart';
import 'package:mentra_app/providers/theme_provider.dart';
import 'package:mentra_app/services/diary_service.dart';
import 'package:provider/provider.dart';

// Varsayılan AdvicePage tanımı
class AdvicePage extends StatefulWidget {
  const AdvicePage({super.key});
  @override
  State<AdvicePage> createState() => _AdvicePageState();
}

class _AdvicePageState extends State<AdvicePage> {
  List<Map<String, dynamic>> analyses = [];
  bool isLoading = true;
  String? errorMessage;

  int _estimateHappinessPercent(String text) {
    if (text.isEmpty) return 50;
    final lower = text.toLowerCase();
    final positives = [
      'happy',
      'joy',
      'great',
      'good',
      'love',
      'wonderful',
      'optimistic',
      'positive',
      'success',
      'calm',
      'peace',
      'glad',
      'smile',
    ];
    final negatives = [
      'sad',
      'anxious',
      'worry',
      'stress',
      'angry',
      'bad',
      'pain',
      'cry',
      'depress',
      'fear',
      'lonely',
      'tired',
      'hopeless',
    ];
    int p = 0;
    int n = 0;
    for (final w in positives) {
      if (lower.contains(w)) p++;
    }
    for (final w in negatives) {
      if (lower.contains(w)) n++;
    }
    final score = (p - n).clamp(-10, 10);
    final percent = ((score + 10) * 5).toInt();
    return percent.clamp(0, 100);
  }

  String _emojiFor(int percent) {
    if (percent >= 75) return '😄';
    if (percent >= 50) return '😐';
    if (percent >= 25) return '😕';
    return '😭';
  }

  @override
  void initState() {
    super.initState();
    _loadAnalyses();
  }

  Future<void> _loadAnalyses() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
      final items = await DiaryService.getAnalysisHistory(limit: 50);
      setState(() {
        analyses = items;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Tavsiyeler yüklenemedi.';
      });
    }
  }

  String _titleFromAdvice(String advice) {
    final text = advice.trim();
    if (text.isEmpty) return 'Advice';
    final dot = text.indexOf('.');
    final first = dot > 0 ? text.substring(0, dot) : text.split('\n').first;
    return first.length <= 60 ? first : '${first.substring(0, 60)}...';
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: themeProvider.isDarkMode
          ? const Color(0xFF121212)
          : const Color(0xFFE8F4F9),
      appBar: AppBar(
        title: const Text('Advice'),
        actions: [
          IconButton(onPressed: _loadAnalyses, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(
              child: Text(
                errorMessage!,
                style: TextStyle(
                  color: themeProvider.isDarkMode
                      ? Colors.redAccent[100]
                      : Colors.redAccent,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: analyses.length,
              itemBuilder: (context, index) {
                final item = analyses[index];
                final dateText = item['formattedDate'] ?? item['date'] ?? '';
                final adviceText = item['advice'] ?? '';
                final title = _titleFromAdvice(adviceText);
                final percent = _estimateHappinessPercent(adviceText);
                final emoji = _emojiFor(percent);
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AdviceDetailPage(analysisItem: item, title: title),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: themeProvider.isDarkMode
                          ? const Color(0xFF1E1E1E)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: themeProvider.isDarkMode
                            ? Colors.grey.shade700
                            : Colors.black12,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: themeProvider.isDarkMode
                              ? Colors.black54
                              : Colors.black12,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dateText,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: themeProvider.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: themeProvider.isDarkMode
                                      ? Colors.white70
                                      : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: themeProvider.isDarkMode
                                ? Colors.yellow.shade800
                                : Colors.yellow.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
*/
