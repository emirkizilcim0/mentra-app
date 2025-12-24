// services/mood_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mentra_app/models/mood_data.dart';
import 'package:mentra_app/services/dairy/dairy_auth.dart';

enum MoodRange { day, week, month }

class MoodRepository {
  Future<List<MoodData>> fetchMoodTrend(MoodRange range) async {
    try {
      // Get Firebase user ID
      final userId = DiaryAuth.getUserId();
      print('🔍 Fetching mood data for Firebase user: $userId, range: $range');

      // ✅ Use /analyses endpoint with user_id query parameter
      final uri = Uri.parse(
        'https://mentra-app-b2ei.onrender.com/analyses?user_id=$userId&limit=100',
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> analyses = json.decode(response.body);
        print('📊 Found ${analyses.length} analyses from API');

        // Convert API data to MoodData objects
        List<MoodData> allMoodData = [];
        for (var analysis in analyses) {
          try {
            final dateStr = analysis['created_at'] ?? analysis['date'];
            final moodStr = analysis['mood']?.toString() ?? 'Calm';
            final advice = analysis['advice'] ?? analysis['analysis'] ?? '';

            if (dateStr != null && moodStr.isNotEmpty) {
              final date = DateTime.parse(dateStr);
              allMoodData.add(
                MoodData.fromString(
                  date: date,
                  moodString: moodStr,
                  advice: advice,
                ),
              );
              print('   ✓ ${date.toLocal()} - $moodStr');
            }
          } catch (e) {
            print('⚠️ Error parsing analysis: $e');
          }
        }

        // Sort by date (newest first)
        allMoodData.sort((a, b) => b.date.compareTo(a.date));

        // Filter based on range
        final now = DateTime.now();
        List<MoodData> filteredData = [];

        switch (range) {
          case MoodRange.day:
            // Today only
            final today = DateTime(now.year, now.month, now.day);
            filteredData = allMoodData.where((mood) {
              final moodDate = DateTime(
                mood.date.year,
                mood.date.month,
                mood.date.day,
              );
              return moodDate == today;
            }).toList();

            // If no data for today, use the latest
            if (filteredData.isEmpty && allMoodData.isNotEmpty) {
              filteredData = [allMoodData.first];
            }
            break;

          case MoodRange.week:
            // Last 7 days
            final weekAgo = now.subtract(const Duration(days: 7));
            filteredData = allMoodData
                .where((mood) => mood.date.isAfter(weekAgo))
                .toList();

            // If we have less than 7 days of data, fill with empty days
            if (filteredData.length < 7) {
              filteredData = _fillMissingDays(filteredData, 7);
            }

            // Take only last 7 days
            filteredData = filteredData.take(7).toList();
            break;

          case MoodRange.month:
            // Last 30 days
            final monthAgo = now.subtract(const Duration(days: 30));
            filteredData = allMoodData
                .where((mood) => mood.date.isAfter(monthAgo))
                .toList();

            // If we have more than 10 points, group by week
            if (filteredData.length > 10) {
              filteredData = _groupByWeek(filteredData);
            }

            // Take max 12 data points for month view
            if (filteredData.length > 12) {
              filteredData = filteredData.sublist(filteredData.length - 12);
            }
            break;
        }

        // Sort oldest to newest for chart
        filteredData.sort((a, b) => a.date.compareTo(b.date));

        print('✅ Final data count for $range: ${filteredData.length}');

        // If still no data, generate sample
        if (filteredData.isEmpty) {
          print('📝 No real data, generating sample');
          return _getSampleData(range);
        }

        return filteredData;
      } else {
        print('❌ API Error: ${response.statusCode} - ${response.body}');
        return _getSampleData(range);
      }
    } catch (e) {
      print('❌ Error fetching mood trend: $e');
      return _getSampleData(range);
    }
  }

  // Fill missing days with placeholder mood data
  List<MoodData> _fillMissingDays(List<MoodData> data, int days) {
    final now = DateTime.now();
    final List<MoodData> filledData = [];

    // Create a map of date to mood for easy lookup
    final Map<String, MoodData> dateMap = {};
    for (var mood in data) {
      final key = '${mood.date.year}-${mood.date.month}-${mood.date.day}';
      dateMap[key] = mood;
    }

    // Generate data for last N days
    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key = '${date.year}-${date.month}-${date.day}';

      if (dateMap.containsKey(key)) {
        // Use existing mood data
        filledData.add(dateMap[key]!);
      } else {
        // Create placeholder with "no data" mood
        filledData.add(
          MoodData(
            date: date,
            mood: Mood.calm, // Default for no data
            moodScore: 3.0, // Neutral score
            advice: 'No analysis for this day',
          ),
        );
      }
    }

    return filledData;
  }

  // Group data by week for month view (average mood per week)
  List<MoodData> _groupByWeek(List<MoodData> data) {
    if (data.isEmpty) return [];

    final Map<int, List<MoodData>> weeklyGroups = {};

    for (var mood in data) {
      // Calculate week number since epoch
      final daysSinceEpoch = mood.date.difference(DateTime(1970)).inDays;
      final weekNumber = (daysSinceEpoch / 7).floor();

      if (!weeklyGroups.containsKey(weekNumber)) {
        weeklyGroups[weekNumber] = [];
      }
      weeklyGroups[weekNumber]!.add(mood);
    }

    final List<MoodData> weeklyAverages = [];

    weeklyGroups.forEach((weekNumber, moods) {
      if (moods.isNotEmpty) {
        // Calculate average mood score for the week
        final avgScore =
            moods.map((m) => m.moodScore).reduce((a, b) => a + b) /
            moods.length;

        // Convert score back to mood
        final avgMood = _scoreToMood(avgScore);

        // Use the first date of the week
        final firstMood = moods.first;

        weeklyAverages.add(
          MoodData(
            date: firstMood.date,
            mood: avgMood,
            moodScore: avgScore,
            advice: 'Weekly average',
          ),
        );
      }
    });

    weeklyAverages.sort((a, b) => a.date.compareTo(b.date));

    // Take only last 4 weeks
    return weeklyAverages.length > 4
        ? weeklyAverages.sublist(weeklyAverages.length - 4)
        : weeklyAverages;
  }

  Mood _scoreToMood(double score) {
    if (score >= 4.5) return Mood.happy;
    if (score >= 3.5) return Mood.calm;
    if (score >= 2.5) return Mood.confused;
    if (score >= 1.5) return Mood.anxious;
    if (score >= 0.5) return Mood.sad;
    return Mood.angry;
  }

  List<MoodData> _getSampleData(MoodRange range) {
    final now = DateTime.now();
    final moods = [
      Mood.happy,
      Mood.sad,
      Mood.anxious,
      Mood.calm,
      Mood.confused,
      Mood.angry,
    ];

    final moodScores = [5.0, 1.0, 2.0, 4.0, 3.0, 0.0];

    int dataPoints = 7;
    int daysBetween = 1;

    switch (range) {
      case MoodRange.day:
        dataPoints = 1;
        daysBetween = 0;
        break;
      case MoodRange.week:
        dataPoints = 7;
        daysBetween = 1;
        break;
      case MoodRange.month:
        dataPoints = 12; // 3 weeks * 4 points per week
        daysBetween = 2;
        break;
    }

    final data = List.generate(dataPoints, (index) {
      final daysAgo = (dataPoints - 1 - index) * daysBetween;
      final date = now.subtract(Duration(days: daysAgo));
      final moodIndex = index % moods.length;

      return MoodData(
        date: date,
        mood: moods[moodIndex],
        moodScore: moodScores[moodIndex],
        advice: 'Sample analysis ${index + 1}',
      );
    });

    print('📊 Generated ${data.length} sample data points for $range');
    return data;
  }

  String formatLabel(DateTime date, MoodRange range) {
    switch (range) {
      case MoodRange.day:
        return 'Today';
      case MoodRange.week:
        return _getDayName(date.weekday);
      case MoodRange.month:
        return 'W${_getWeekOfMonth(date)}';
    }
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  int _getWeekOfMonth(DateTime date) {
    final firstDay = DateTime(date.year, date.month, 1);
    final daysDiff = date.difference(firstDay).inDays;
    return (daysDiff / 7).floor() + 1;
  }
}
