// pages/mood/mood_graph_page.dart
import 'dart:ui';

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
  bool _isLoading = true;
  bool _hasRealData = false;
  int _dataCount = 0;

  @override
  void initState() {
    super.initState();
    print('📊 MoodGraphPage initialized');
    _load();
  }

  void _load() {
    setState(() {
      _isLoading = true;
    });

    print('🔄 Loading mood data for range: $_range');
    _future = _repo
        .fetchMoodTrend(_range)
        .then((data) {
          print('✅ Loaded ${data.length} mood data points');

          // Check if we have real data (not sample)
          _hasRealData = data.any(
            (mood) =>
                !mood.advice.contains('Sample') &&
                !mood.advice.contains('No analysis'),
          );
          _dataCount = data.length;

          setState(() {
            _isLoading = false;
          });

          return data;
        })
        .catchError((error) {
          print('❌ Error loading mood data: $error');
          setState(() {
            _isLoading = false;
          });
          return <MoodData>[];
        });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      // AppBar tamamen kaldırıldı, body içinde Stack ile yönetiliyor
      body: Stack(
        children: [
          // 1. ANA İÇERİK
          Container(
            decoration: BoxDecoration(
              gradient: MoodGraphStyles.getBackground(isDark),
            ),
            child: Padding(
              // Üstten 110 padding vererek içeriğin yüzen barın altında kalmamasını sağladık
              padding: const EdgeInsets.fromLTRB(16, 110, 16, 90),
              child: FutureBuilder<List<MoodData>>(
                future: _future,
                builder: (context, snapshot) {
                  if (_isLoading) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading mood data...'),
                        ],
                      ),
                    );
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

                  if (data.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.insights_outlined,
                            size: 60,
                            color: MoodGraphStyles.getTextColor(
                              isDark,
                            ).withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No mood data available',
                            style: TextStyle(
                              color: MoodGraphStyles.getTextColor(isDark),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Go to Diaries'),
                          ),
                        ],
                      ),
                    );
                  }

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
                        if (!_hasRealData && data.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.orange.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  color: Colors.orange,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Showing sample data. Analyze your diaries to see real mood trends.',
                                    style: TextStyle(
                                      color: MoodGraphStyles.getTextColor(
                                        isDark,
                                      ),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 16),
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
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // 2. ÜST YÜZEN TOP BAR (Yeni Tasarım)
          Positioned(
            top: statusBarHeight + 10,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Başlık Kapsülü
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.black : Colors.white)
                            .withOpacity(0.3),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withOpacity(isDark ? 0.2 : 0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.insights_rounded,
                            color: isDark ? Colors.purpleAccent : Colors.purple,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Mood Tracker",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Data Count Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _hasRealData
                                  ? Colors.green.withOpacity(0.2)
                                  : Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _hasRealData
                                    ? Colors.green
                                    : Colors.orange,
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              '$_dataCount',
                              style: TextStyle(
                                fontSize: 10,
                                color: _hasRealData
                                    ? Colors.green
                                    : Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Refresh Butonu Kapsülü
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.black : Colors.white)
                            .withOpacity(0.3),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withOpacity(isDark ? 0.2 : 0.5),
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.refresh_rounded,
                          color: isDark ? Colors.white : Colors.black87,
                          size: 24,
                        ),
                        onPressed: _load,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. ALT BAR
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
          Row(
            children: [
              Text(
                'Recent Moods',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: MoodGraphStyles.getTextColor(isDark),
                ),
              ),
              const SizedBox(width: 8),
              if (!_hasRealData)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Sample',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
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
                        if (mood.advice.isNotEmpty && mood.advice.length < 50)
                          Text(
                            mood.advice,
                            style: TextStyle(
                              fontSize: 10,
                              color: MoodGraphStyles.getTextColor(
                                isDark,
                              ).withOpacity(0.5),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
