// lib/pages/mood/mood_bar_chart.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mentra_app/models/mood_data.dart';
import 'package:mentra_app/services/mood_repository.dart';
import 'mood_graph_styles.dart';

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
  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: MoodGraphStyles.getChartContainerDecoration(isDark),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bar_chart,
                size: 40,
                color: MoodGraphStyles.getTextColor(isDark).withOpacity(0.3),
              ),
              const SizedBox(height: 12),
              Text(
                'No mood data available for chart',
                style: TextStyle(
                  color: MoodGraphStyles.getTextColor(isDark),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }
    final textColor = MoodGraphStyles.getTextColor(isDark);
    final gridColor = MoodGraphStyles.getGridColor(isDark);

    // Aralığı burada hesaplıyoruz
    // Range parametresini de ekliyoruz
    final double interval = _getXAxisInterval(range, data.length);
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
                maxY: 5,
                minY: 0,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: gridColor, strokeWidth: 1),
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
                    showingTooltipIndicators: [],
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        const moods = [
                          'Angry',
                          'Sad',
                          'Anxious',
                          'Confused',
                          'Calm',
                          'Happy',
                        ];
                        int index = value.toInt();
                        if (index >= 0 && index < moods.length) {
                          return Text(
                            moods[index],
                            style: TextStyle(color: textColor, fontSize: 10),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      interval: interval, // Aralığı buraya veriyoruz
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();

                        // KİLİT NOKTA: Eğer index aralığa tam bölünmüyorsa hiç çizme!
                        // Bu, üst üste binmeyi %100 engeller.
                        if (index % interval.toInt() != 0) {
                          return const SizedBox.shrink();
                        }

                        if (index >= 0 && index < data.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              _formatLabel(
                                data[index],
                                range,
                                index,
                                data.length,
                              ),
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
                barTouchData: BarTouchData(enabled: false),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildMoodStats(data, textColor),
        ],
      ),
    );
  }

  // --- HELPER METHODS ---

  // Dinamik aralık hesaplama: Ekrana en fazla 6-7 etiket sığsın
  // DÜZELTİLMİŞ ARALIK HESAPLAMA
  double _getXAxisInterval(MoodRange range, int dataLength) {
    switch (range) {
      case MoodRange.day:
        // Sadece 'Today' modunda veriler çoksa sıkıştırma yap
        if (dataLength <= 6) return 1;
        return (dataLength / 6).ceilToDouble();

      case MoodRange.week:
        // Haftalık görünümde ASLA atlama yapma, her günü göster (Interval = 1)
        return 1;

      case MoodRange.month:
        // Aylık görünümde her haftayı göster (Interval = 1)
        return 1;
    }
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
        if (dataLength > 20) return 6;
        if (dataLength > 10) return 10;
        return 16;
      case MoodRange.week:
        return 14;
      case MoodRange.month:
        return 12;
    }
  }

  // index ve dataLength parametrelerini ekledik
  String _formatLabel(
    MoodData mood,
    MoodRange range,
    int index,
    int dataLength,
  ) {
    switch (range) {
      case MoodRange.day:
        // Saat ve dakika (Örn: 14:30)
        return '${mood.date.hour.toString().padLeft(2, '0')}:${mood.date.minute.toString().padLeft(2, '0')}';

      case MoodRange.week:
        // HİLE BURADA: Verinin tarihi ne olursa olsun, grafikteki sırasına göre gün atıyoruz.
        // Son veri (en sağdaki) = Bugün
        // Bir önceki = Dün
        final now = DateTime.now();
        // Geriye doğru hesaplama: (Toplam veri - 1 - index) gün kadar geriye git
        final calculatedDate = now.subtract(
          Duration(days: dataLength - 1 - index),
        );

        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        return days[calculatedDate.weekday - 1];

      case MoodRange.month:
        return 'W${_getWeekNumber(mood.date)}';
    }
  }

  int _getWeekNumber(DateTime date) {
    final firstDay = DateTime(date.year, date.month, 1);
    final daysDiff = date.difference(firstDay).inDays;
    return (daysDiff / 7).floor() + 1;
  }

  Widget _buildMoodStats(List<MoodData> data, Color textColor) {
    if (data.isEmpty) return Container();
    final moodCounts = <Mood, int>{};
    for (var moodData in data)
      moodCounts[moodData.mood] = (moodCounts[moodData.mood] ?? 0) + 1;
    Mood? mostCommonMood;
    int maxCount = 0;
    moodCounts.forEach((mood, count) {
      if (count > maxCount) {
        maxCount = count;
        mostCommonMood = mood;
      }
    });
    final avgScore =
        data.map((d) => d.moodScore).reduce((a, b) => a + b) / data.length;
    final avgMood = _scoreToMood(avgScore);

    final commonMoodData = mostCommonMood != null
        ? MoodData(date: DateTime.now(), mood: mostCommonMood!)
        : null;
    final avgMoodData = MoodData(date: DateTime.now(), mood: avgMood);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          'Most Common',
          commonMoodData?.moodLabel ?? 'N/A',
          commonMoodData?.moodColor ?? textColor,
          textColor,
        ),
        _buildStatItem(
          'Average Mood',
          avgMoodData.moodLabel,
          avgMoodData.moodColor,
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
