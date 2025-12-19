/*
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'services/mood_repository.dart';
import 'models/mood_data.dart';

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
    _future = _repo.fetchMoodTrend(_range);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bg = themeProvider.isDarkMode
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF121212), Color(0xFF1E1E1E)],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF7F9FC), Color(0xFFFFFFFF)],
          );

    final lineColor = themeProvider.isDarkMode
        ? const Color(0xFF80CBC4)
        : const Color(0xFF26A69A);
    final gridColor = themeProvider.isDarkMode
        ? Colors.white10
        : Colors.black12;
    final textColor = themeProvider.isDarkMode
        ? Colors.white
        : Colors.black87;

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            themeProvider.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        title: Text(
          'Mood Graph',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme:
            IconThemeData(color: themeProvider.isDarkMode ? Colors.white : Colors.black),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: bg),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FutureBuilder<List<MoodData>>(
            future: _future,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final data = snapshot.data!;
              final spots = List.generate(
                data.length,
                (i) => FlSpot(i.toDouble(), data[i].moodScore),
              );

              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        label: const Text('Hafta'),
                        selected: _range == MoodRange.week,
                        onSelected: (v) {
                          setState(() {
                            _range = MoodRange.week;
                            _future = _repo.fetchMoodTrend(_range);
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Ay'),
                        selected: _range == MoodRange.month,
                        onSelected: (v) {
                          setState(() {
                            _range = MoodRange.month;
                            _future = _repo.fetchMoodTrend(_range);
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Yıl'),
                        selected: _range == MoodRange.year,
                        onSelected: (v) {
                          setState(() {
                            _range = MoodRange.year;
                            _future = _repo.fetchMoodTrend(_range);
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: themeProvider.isDarkMode
                          ? const Color(0xFF1E1E1E)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: themeProvider.isDarkMode
                              ? Colors.black54
                              : Colors.black12,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      height: 260,
                      child: LineChart(
                        LineChartData(
                          minY: 0,
                          maxY: 100,
                          gridData: FlGridData(
                            show: true,
                            getDrawingHorizontalLine: (v) => FlLine(
                              color: gridColor,
                              strokeWidth: 1,
                            ),
                            getDrawingVerticalLine: (v) => FlLine(
                              color: gridColor,
                              strokeWidth: 1,
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 36,
                                getTitlesWidget: (value, meta) {
                                  if (value % 25 != 0) return const SizedBox.shrink();
                                  return Text('${value.toInt()}%', style: TextStyle(color: textColor, fontSize: 12));
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 36,
                                getTitlesWidget: (value, meta) {
                                  final i = value.toInt();
                                  if (i < 0 || i >= data.length) return const SizedBox.shrink();
                                  final step = _range == MoodRange.year
                                      ? 1
                                      : (_range == MoodRange.month ? 3 : 1);
                                  if (i % step != 0) return const SizedBox.shrink();
                                  final label = _repo.formatLabel(data[i].date, _range);
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Transform.rotate(
                                      angle: _range == MoodRange.month ? -0.6 : 0,
                                      child: Text(
                                        label,
                                        style: TextStyle(color: textColor, fontSize: 11),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
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
                                    lineColor.withValues(alpha: 0.25),
                                    lineColor.withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: themeProvider.isDarkMode
                          ? const Color(0xFF1E1E1E)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: themeProvider.isDarkMode
                              ? Colors.black54
                              : Colors.black12,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      height: 220,
                      child: BarChart(
                        BarChartData(
                          maxY: 100,
                          gridData: FlGridData(show: true, drawVerticalLine: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true, reservedSize: 32, getTitlesWidget: (v, m) {
                                if (v % 25 != 0) return const SizedBox.shrink();
                                return Text('${v.toInt()}%', style: TextStyle(color: textColor, fontSize: 11));
                              }),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true, reservedSize: 36, getTitlesWidget: (v, m) {
                                final i = v.toInt();
                                if (i < 0 || i >= data.length) return const SizedBox.shrink();
                                final step = _range == MoodRange.year ? 1 : (_range == MoodRange.month ? 3 : 1);
                                if (i % step != 0) return const SizedBox.shrink();
                                final label = _repo.formatLabel(data[i].date, _range);
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Transform.rotate(
                                    angle: _range == MoodRange.month ? -0.6 : 0,
                                    child: Text(label, style: TextStyle(color: textColor, fontSize: 11)),
                                  ),
                                );
                              }),
                            ),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: List.generate(data.length, (i) {
                            return BarChartGroupData(x: i, barRods: [
                              BarChartRodData(
                                toY: data[i].moodScore,
                                color: lineColor,
                                borderRadius: BorderRadius.circular(6),
                                width: _range == MoodRange.year ? 14 : (_range == MoodRange.month ? 6 : 18),
                                rodStackItems: [],
                              ),
                            ]);
                          }),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'This data was generated by AI based on your daily analysis.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
*/
