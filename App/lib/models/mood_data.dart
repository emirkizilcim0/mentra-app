// models/mood_data.dart
import 'package:flutter/material.dart';

enum Mood { angry, sad, anxious, confused, calm, happy }

class MoodData {
  final DateTime date;
  final Mood mood;
  final double moodScore;
  final String advice;

  MoodData({
    required this.date,
    required this.mood,
    this.moodScore = 0.0,
    this.advice = '',
  });

  factory MoodData.fromString({
    required DateTime date,
    required String moodString,
    String advice = '',
  }) {
    final mood = _stringToMood(moodString);
    final score = _moodToScore(mood);

    return MoodData(date: date, mood: mood, moodScore: score, advice: advice);
  }

  static Mood _stringToMood(String moodStr) {
    final lowerMood = moodStr.toLowerCase();

    if (lowerMood.contains('happy')) return Mood.happy;
    if (lowerMood.contains('calm')) return Mood.calm;
    if (lowerMood.contains('confused')) return Mood.confused;
    if (lowerMood.contains('anxious')) return Mood.anxious;
    if (lowerMood.contains('sad')) return Mood.sad;
    if (lowerMood.contains('angry')) return Mood.angry;

    // Default to calm if unknown
    return Mood.calm;
  }

  static double _moodToScore(Mood mood) {
    switch (mood) {
      case Mood.angry:
        return 0.0;
      case Mood.sad:
        return 1.0;
      case Mood.anxious:
        return 2.0;
      case Mood.confused:
        return 3.0;
      case Mood.calm:
        return 4.0;
      case Mood.happy:
        return 5.0;
    }
  }

  // Helper getters
  Color get moodColor {
    switch (mood) {
      case Mood.angry:
        return Colors.red;
      case Mood.sad:
        return Colors.blue;
      case Mood.anxious:
        return Colors.orange;
      case Mood.confused:
        return Colors.purple;
      case Mood.calm:
        return Colors.green;
      case Mood.happy:
        return Colors.yellow;
    }
  }

  String get moodLabel {
    switch (mood) {
      case Mood.angry:
        return 'Angry';
      case Mood.sad:
        return 'Sad';
      case Mood.anxious:
        return 'Anxious';
      case Mood.confused:
        return 'Confused';
      case Mood.calm:
        return 'Calm';
      case Mood.happy:
        return 'Happy';
    }
  }

  String get moodEmoji {
    switch (mood) {
      case Mood.angry:
        return '😠';
      case Mood.sad:
        return '😢';
      case Mood.anxious:
        return '😰';
      case Mood.confused:
        return '😕';
      case Mood.calm:
        return '😌';
      case Mood.happy:
        return '😊';
    }
  }

  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  @override
  String toString() {
    return 'MoodData{date: $date, mood: $mood, score: $moodScore}';
  }
}
