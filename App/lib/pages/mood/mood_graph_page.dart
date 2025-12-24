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
          // Data info badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: _hasRealData
                  ? Colors.green.withOpacity(0.2)
                  : Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _hasRealData ? Colors.green : Colors.orange,
                width: 1,
              ),
            ),
            child: Text(
              '${_dataCount} data',
              style: TextStyle(
                fontSize: 12,
                color: _hasRealData ? Colors.green : Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
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
                          const SizedBox(height: 8),
                          Text(
                            snapshot.error.toString(),
                            style: TextStyle(
                              color: MoodGraphStyles.getTextColor(
                                isDark,
                              ).withOpacity(0.7),
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
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
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              'Analyze your diaries to see mood trends and insights',
                              style: TextStyle(
                                color: MoodGraphStyles.getTextColor(
                                  isDark,
                                ).withOpacity(0.6),
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              // Navigate to diary or analysis page
                              Navigator.pop(context);
                            },
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

                        // Info banner if using sample data
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
                                Icon(Icons.info_outline, color: Colors.orange),
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
