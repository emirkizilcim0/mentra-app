import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WriteLogic {
  static void saveDiary(
    BuildContext context,
    GlobalKey<FormState> key,
    String title,
    String content,
  ) {
    if (key.currentState!.validate()) {
      final now = DateTime.now();

      final diaryEntry = {
        'id': now.millisecondsSinceEpoch.toString(),
        'title': title,
        'content': content,
        'date': now.toIso8601String(),
        'formattedDate': DateFormat('dd MMMM yyyy, HH:mm').format(now),
      };

      Navigator.pop(context, diaryEntry);
    }
  }
}
