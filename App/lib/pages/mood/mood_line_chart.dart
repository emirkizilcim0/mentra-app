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
    final lineColor = MoodGraphStyles.getLineColor(isDark);
    final gridColor = MoodGraphStyles.getGridColor(isDark);
    final textColor = MoodGraphStyles.getTextColor(isDark);
    final spots = List.generate(
      data.length,
      (i) => FlSpot(i.toDouble(), data[i].moodScore),
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: MoodGraphStyles.getChartContainerDecoration(isDark),
      child: SizedBox(
        height: 260,
        child: LineChart(
          LineChartData(
            minY: 0,
            maxY: 100,
            gridData: FlGridData(
              show: true,
              getDrawingHorizontalLine: (_) => FlLine(color: gridColor),
              getDrawingVerticalLine: (_) => FlLine(color: gridColor),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: lineColor,
                barWidth: 3,
                dotData: FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      lineColor.withOpacity(0.25),
                      lineColor.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ],
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 36,
                  getTitlesWidget: (v, m) => v % 25 == 0
                      ? Text(
                          '${v.toInt()}%',
                          style: TextStyle(color: textColor, fontSize: 12),
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
          ),
        ),
      ),
    );
  }
}
