// pages/mood/mood_line_chart.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mentra_app/models/mood_data.dart';
import 'package:mentra_app/services/mood_repository.dart';
import 'mood_graph_styles.dart';

class MoodLineChart extends StatelessWidget {
  final List<MoodData> data;
  final MoodRange range;
  final bool isDark;

  const MoodLineChart({
    super.key,
    required this.data,
    required this.range,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return _buildEmptyState(isDark);
    }

    final lineColor = MoodGraphStyles.getLineColor(isDark);
    final gridColor = MoodGraphStyles.getGridColor(isDark);
    final textColor = MoodGraphStyles.getTextColor(isDark);

    // Convert mood data to chart spots
    final spots = List.generate(
      data.length,
      (i) => FlSpot(i.toDouble(), data[i].moodScore),
    );

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
                'Mood Trend',
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
            height: 200,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 5, // 0-5 scale for moods
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  drawVerticalLine: range == MoodRange.month,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(color: gridColor, strokeWidth: 1);
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: gridColor.withOpacity(0.3),
                      strokeWidth: 0.5,
                    );
                  },
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: gridColor),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: lineColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: data[index].moodColor,
                          strokeWidth: 2,
                          strokeColor: isDark ? Colors.black : Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          lineColor.withOpacity(0.3),
                          lineColor.withOpacity(0.1),
                        ],
                      ),
                    ),
                  ),
                ],
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
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final index = spot.spotIndex;
                        final mood = data[index];
                        return LineTooltipItem(
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
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Current mood info
          if (data.isNotEmpty) _buildCurrentMood(data.last, isDark, textColor),
        ],
      ),
    );
  }

  String _getRangeLabel(MoodRange range) {
    switch (range) {
      case MoodRange.day:
        return 'Today';
      case MoodRange.week:
        return 'Last 7 days';
      case MoodRange.month:
        return 'Last 4 weeks';
    }
  }

  double _getXAxisInterval(MoodRange range, int dataLength) {
    switch (range) {
      case MoodRange.day:
        return 1;
      case MoodRange.week:
        return 1; // Show every day
      case MoodRange.month:
        return 1; // Show every week
    }
  }

  String _formatLabel(MoodData mood, MoodRange range) {
    switch (range) {
      case MoodRange.day:
        return 'Now';
      case MoodRange.week:
        return mood.dayName; // Mon, Tue, etc.
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

  Widget _buildCurrentMood(MoodData latestMood, bool isDark, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: latestMood.moodColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: latestMood.moodColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: latestMood.moodColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                latestMood.moodEmoji,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Mood: ${latestMood.moodLabel}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: latestMood.moodColor,
                  ),
                ),
                Text(
                  _formatDate(latestMood.date),
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: MoodGraphStyles.getChartContainerDecoration(isDark),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.insights,
              size: 40,
              color: MoodGraphStyles.getTextColor(isDark).withOpacity(0.3),
            ),
            const SizedBox(height: 12),
            Text(
              'No mood data available',
              style: TextStyle(
                color: MoodGraphStyles.getTextColor(isDark),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Start analyzing your diaries',
              style: TextStyle(
                color: MoodGraphStyles.getTextColor(isDark).withOpacity(0.6),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
