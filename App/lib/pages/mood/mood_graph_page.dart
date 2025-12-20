// pages/mood/mood_graph_page.dart
import 'package:flutter/material.dart';
import 'package:mentra_app/pages/mood/mood_bar_chart.dart';
import 'package:mentra_app/pages/mood/mood_graph_bottom_nav.dart';
import 'package:mentra_app/pages/mood/mood_graph_styles.dart';
import 'package:mentra_app/pages/mood/mood_line_chart.dart';
import 'package:mentra_app/pages/mood/range_selector.dart';
import 'package:provider/provider.dart';
import 'package:mentra_app/providers/theme_provider.dart';
import 'package:mentra_app/services/mood_repository.dart';
import 'package:mentra_app/models/mood_data.dart';

class MoodGraphPage extends StatefulWidget {
  const MoodGraphPage({super.key});
  @override
  State<MoodGraphPage> createState() => _MoodGraphPageState();
}

class _MoodGraphPageState extends State<MoodGraphPage> {
  final MoodRepository _repo = MoodRepository();
  late Future<List<MoodData>> _future;
  MoodRange _range = MoodRange.week;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _future = _repo.fetchMoodTrend(_range);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mood Tracker',
          style: TextStyle(
            color: MoodGraphStyles.getTextColor(isDark),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
            tooltip: 'Refresh data',
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: MoodGraphStyles.getBackground(isDark),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              child: FutureBuilder<List<MoodData>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 50,
                            color: Colors.red.withOpacity(0.7),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Could not load mood data',
                            style: TextStyle(
                              color: MoodGraphStyles.getTextColor(isDark),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Check your internet connection',
                            style: TextStyle(
                              color: MoodGraphStyles.getTextColor(
                                isDark,
                              ).withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _load,
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    );
                  }

                  final data = snapshot.data ?? [];

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        Center(
                          child: RangeSelector(
                            selectedRange: _range,
                            onRangeSelected: (newRange) {
                              setState(() {
                                _range = newRange;
                                _load();
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        MoodLineChart(
                          data: data,
                          range: _range,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 20),
                        MoodBarChart(data: data, range: _range, isDark: isDark),
                        const SizedBox(height: 20),
                        if (data.isNotEmpty) _buildMoodHistory(data, isDark),
                        const SizedBox(height: 20),
                        Text(
                          'Mood data is generated from your diary analyses',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Write more diaries for better insights',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isDark ? Colors.white60 : Colors.black45,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          const MoodGraphBottomNav(),
        ],
      ),
    );
  }

  Widget _buildMoodHistory(List<MoodData> data, bool isDark) {
    // Take only last 5 entries
    final recentMoods = data.length > 5 ? data.sublist(data.length - 5) : data;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: MoodGraphStyles.getChartContainerDecoration(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Moods',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: MoodGraphStyles.getTextColor(isDark),
            ),
          ),
          const SizedBox(height: 12),
          ...recentMoods.reversed.map((mood) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: mood.moodColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Center(
                      child: Text(
                        mood.moodEmoji,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mood.moodLabel,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: mood.moodColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatMoodDate(mood.date),
                          style: TextStyle(
                            fontSize: 12,
                            color: MoodGraphStyles.getTextColor(
                              isDark,
                            ).withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatTime(mood.date),
                    style: TextStyle(
                      fontSize: 12,
                      color: MoodGraphStyles.getTextColor(
                        isDark,
                      ).withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  String _formatMoodDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final moodDay = DateTime(date.year, date.month, date.day);

    if (moodDay == today) {
      return 'Today';
    } else if (moodDay == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
