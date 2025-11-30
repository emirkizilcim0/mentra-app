import 'package:intl/intl.dart';
import '../models/mood_data.dart';

enum MoodRange { week, month, year }

class MoodRepository {
  Future<List<MoodData>> fetchMoodTrend(MoodRange range) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();

    if (range == MoodRange.week) {
      final start = now.subtract(Duration(days: now.weekday % 7));
      return List.generate(7, (i) {
        final date = start.add(Duration(days: i));
        final score = [20.0, 35.0, 50.0, 80.0, 65.0, 75.0, 55.0][i];
        return MoodData(date: date, moodScore: score);
      });
    }

    if (range == MoodRange.month) {
      final start = DateTime(now.year, now.month, 1);
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      return List.generate(daysInMonth, (i) {
        final date = start.add(Duration(days: i));
        final base = (i % 10) * 7.0 + 15.0;
        final jitter = ((i * 13) % 12).toDouble();
        final score = (base + jitter).clamp(10.0, 95.0);
        return MoodData(date: date, moodScore: score);
      });
    }

    final months = List.generate(12, (i) => DateTime(now.year, i + 1, 15));
    final scores = List.generate(12, (i) => (20 + i * 5 + (i % 3) * 7).toDouble().clamp(10.0, 95.0));
    return List.generate(12, (i) => MoodData(date: months[i], moodScore: scores[i]));
  }

  String formatLabel(DateTime d, MoodRange range) {
    switch (range) {
      case MoodRange.week:
        return DateFormat('E').format(d);
      case MoodRange.month:
        return DateFormat('d').format(d);
      case MoodRange.year:
        return DateFormat('MMM').format(d);
    }
  }
}
