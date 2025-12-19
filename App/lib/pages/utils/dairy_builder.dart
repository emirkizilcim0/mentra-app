import 'package:intl/intl.dart';

Map<String, dynamic> buildDiaryEntry(String title, String content) {
  final now = DateTime.now();
  return {
    'id': now.millisecondsSinceEpoch.toString(),
    'title': title,
    'content': content,
    'date': now.toIso8601String(),
    'formattedDate': DateFormat('dd MMMM yyyy, HH:mm').format(now),
  };
}
