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
  Widget build(BuildContext context) {
    final barColor = MoodGraphStyles.getLineColor(isDark);
    final textColor = MoodGraphStyles.getTextColor(isDark);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: MoodGraphStyles.getChartContainerDecoration(isDark),
      child: SizedBox(
        height: 220,
        child: BarChart(
          BarChartData(
            maxY: 100,
            gridData: FlGridData(show: true, drawVerticalLine: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  getTitlesWidget: (v, m) => v % 25 == 0
                      ? Text(
                          '${v.toInt()}%',
                          style: TextStyle(color: textColor, fontSize: 11),
                        )
                      : const SizedBox(),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 36,
                  getTitlesWidget: (v, m) {
                    final i = v.toInt();
                    if (i < 0 ||
                        i >= data.length ||
                        i %
                                (range == MoodRange.year
                                    ? 1
                                    : (range == MoodRange.month ? 3 : 1)) !=
                            0)
                      return const SizedBox();
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Transform.rotate(
                        angle: range == MoodRange.month ? -0.6 : 0,
                        child: Text(
                          MoodRepository().formatLabel(data[i].date, range),
                          style: TextStyle(color: textColor, fontSize: 11),
                        ),
                      ),
                    );
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
            barGroups: List.generate(
              data.length,
              (i) => BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: data[i].moodScore,
                    color: barColor,
                    borderRadius: BorderRadius.circular(6),
                    width: range == MoodRange.year
                        ? 14
                        : (range == MoodRange.month ? 6 : 18),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
