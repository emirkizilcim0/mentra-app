// models/mood_data.dart
import 'package:flutter/material.dart';

enum Mood { happy, sad, anxious, angry, calm, confused }

class MoodData {
  final DateTime date;
  final Mood mood;
  final String? advice;

  const MoodData({required this.date, required this.mood, this.advice});

  // Convert mood to numeric score for charts (0-5 scale)
  double get moodScore {
    switch (mood) {
      case Mood.happy:
        return 5.0;
      case Mood.calm:
        return 4.0;
      case Mood.confused:
        return 3.0;
      case Mood.anxious:
        return 2.0;
      case Mood.sad:
        return 1.0;
      case Mood.angry:
        return 0.0;
    }
  }

  // Get mood color
  Color get moodColor {
    switch (mood) {
      case Mood.happy:
        return Colors.green;
      case Mood.calm:
        return Colors.blue;
      case Mood.confused:
        return Colors.yellow;
      case Mood.anxious:
        return Colors.orange;
      case Mood.sad:
        return Colors.blueGrey;
      case Mood.angry:
        return Colors.red;
    }
  }

  // Get mood emoji
  String get moodEmoji {
    switch (mood) {
      case Mood.happy:
        return '😊';
      case Mood.calm:
        return '😌';
      case Mood.confused:
        return '😕';
      case Mood.anxious:
        return '😰';
      case Mood.sad:
        return '😢';
      case Mood.angry:
        return '😠';
    }
  }

  // Get mood label
  String get moodLabel {
    switch (mood) {
      case Mood.happy:
        return 'Happy';
      case Mood.calm:
        return 'Calm';
      case Mood.confused:
        return 'Confused';
      case Mood.anxious:
        return 'Anxious';
      case Mood.sad:
        return 'Sad';
      case Mood.angry:
        return 'Angry';
    }
  }

  // Factory method to create from string
  factory MoodData.fromString({
    required DateTime date,
    required String moodString,
    String? advice,
  }) {
    final mood = _parseMoodString(moodString);
    return MoodData(date: date, mood: mood, advice: advice);
  }

  static Mood _parseMoodString(String moodString) {
    switch (moodString.toLowerCase()) {
      case 'happy':
        return Mood.happy;
      case 'sad':
        return Mood.sad;
      case 'anxious':
        return Mood.anxious;
      case 'angry':
        return Mood.angry;
      case 'calm':
        return Mood.calm;
      case 'confused':
        return Mood.confused;
      default:
        return Mood.calm;
    }
  }

  // Get day name
  String get dayName {
    switch (date.weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }

  // Get month name
  String get monthName {
    switch (date.month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
  }

  // Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
