// pages/mood/mood_bar_chart.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mentra_app/models/mood_data.dart';
import 'mood_graph_styles.dart';
import 'package:mentra_app/services/mood_repository.dart';

class MoodBarChart extends StatelessWidget {
  final List<MoodData> data;
  final MoodRange range;
  final bool isDark;

  const MoodBarChart({
    super.key,
    required this.data,
    required this.range,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Container(); // Return empty container if no data
    }

    final textColor = MoodGraphStyles.getTextColor(isDark);
    final gridColor = MoodGraphStyles.getGridColor(isDark);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: MoodGraphStyles.getChartContainerDecoration(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mood Overview',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              Text(
                _getRangeLabel(range),
                style: TextStyle(
                  fontSize: 12,
                  color: textColor.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                maxY: 5, // 0-5 scale
                minY: 0,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(color: gridColor, strokeWidth: 1);
                  },
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: gridColor),
                ),
                barGroups: List.generate(
                  data.length,
                  (i) => BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: data[i].moodScore,
                        color: data[i].moodColor,
                        borderRadius: BorderRadius.circular(4),
                        width: _getBarWidth(range, data.length),
                      ),
                    ],
                    showingTooltipIndicators: [0],
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value == 0)
                          return Text(
                            'Angry',
                            style: TextStyle(color: textColor, fontSize: 10),
                          );
                        if (value == 1)
                          return Text(
                            'Sad',
                            style: TextStyle(color: textColor, fontSize: 10),
                          );
                        if (value == 2)
                          return Text(
                            'Anxious',
                            style: TextStyle(color: textColor, fontSize: 10),
                          );
                        if (value == 3)
                          return Text(
                            'Confused',
                            style: TextStyle(color: textColor, fontSize: 10),
                          );
                        if (value == 4)
                          return Text(
                            'Calm',
                            style: TextStyle(color: textColor, fontSize: 10),
                          );
                        if (value == 5)
                          return Text(
                            'Happy',
                            style: TextStyle(color: textColor, fontSize: 10),
                          );
                        return const Text('');
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      interval: _getXAxisInterval(range, data.length),
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < data.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              _formatLabel(data[index], range),
                              style: TextStyle(fontSize: 9, color: textColor),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final mood = data[groupIndex];
                      return BarTooltipItem(
                        '${_formatLabel(mood, range)}\n${mood.moodLabel}',
                        TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                        children: [
                          TextSpan(
                            text: '\n${_formatDate(mood.date)}',
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.grey,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Mood statistics
          _buildMoodStats(data, textColor),
        ],
      ),
    );
  }

  String _getRangeLabel(MoodRange range) {
    switch (range) {
      case MoodRange.day:
        return 'Today';
      case MoodRange.week:
        return 'Daily';
      case MoodRange.month:
        return 'Weekly';
    }
  }

  double _getBarWidth(MoodRange range, int dataLength) {
    switch (range) {
      case MoodRange.day:
        return 30;
      case MoodRange.week:
        return 18;
      case MoodRange.month:
        return 22;
    }
  }

  double _getXAxisInterval(MoodRange range, int dataLength) {
    switch (range) {
      case MoodRange.day:
        return 1;
      case MoodRange.week:
        return 1;
      case MoodRange.month:
        return 1;
    }
  }

  String _formatLabel(MoodData mood, MoodRange range) {
    switch (range) {
      case MoodRange.day:
        return 'Now';
      case MoodRange.week:
        return mood.dayName.substring(0, 1); // M, T, W, etc.
      case MoodRange.month:
        return 'W${_getWeekNumber(mood.date)}';
    }
  }

  int _getWeekNumber(DateTime date) {
    final firstDay = DateTime(date.year, date.month, 1);
    final daysDiff = date.difference(firstDay).inDays;
    return (daysDiff / 7).floor() + 1;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildMoodStats(List<MoodData> data, Color textColor) {
    if (data.isEmpty) return Container();

    // Count each mood
    final moodCounts = <Mood, int>{};
    for (var moodData in data) {
      moodCounts[moodData.mood] = (moodCounts[moodData.mood] ?? 0) + 1;
    }

    // Find most common mood
    Mood? mostCommonMood;
    int maxCount = 0;
    moodCounts.forEach((mood, count) {
      if (count > maxCount) {
        maxCount = count;
        mostCommonMood = mood;
      }
    });

    // Calculate average mood
    final avgScore =
        data.map((d) => d.moodScore).reduce((a, b) => a + b) / data.length;
    final avgMood = _scoreToMood(avgScore);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          'Most Common',
          mostCommonMood != null
              ? MoodData(date: DateTime.now(), mood: mostCommonMood!).moodLabel
              : 'N/A',
          mostCommonMood != null
              ? MoodData(date: DateTime.now(), mood: mostCommonMood!).moodColor
              : textColor,
          textColor,
        ),
        _buildStatItem(
          'Average Mood',
          MoodData(date: DateTime.now(), mood: avgMood).moodLabel,
          MoodData(date: DateTime.now(), mood: avgMood).moodColor,
          textColor,
        ),
        _buildStatItem('Total', '${data.length}', Colors.purple, textColor),
      ],
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    Color valueColor,
    Color textColor,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 10, color: textColor.withOpacity(0.7)),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Mood _scoreToMood(double score) {
    if (score >= 4.5) return Mood.happy;
    if (score >= 3.5) return Mood.calm;
    if (score >= 2.5) return Mood.confused;
    if (score >= 1.5) return Mood.anxious;
    if (score >= 0.5) return Mood.sad;
    return Mood.angry;
  }
}
