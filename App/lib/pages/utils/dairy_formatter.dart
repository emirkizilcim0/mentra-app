import 'package:intl/intl.dart';

String diaryTitle(Map<String, dynamic> entry) {
  return (entry['title'] ?? _titleFromContent(entry['content'] ?? ''))
      .toString();
}

String diaryDate(Map<String, dynamic> entry) {
  return (entry['formattedDate'] ?? _formatDate(entry['date'])).toString();
}

String _titleFromContent(String content) {
  final text = content.trim();
  if (text.isEmpty) return 'Untitled';
  final dot = text.indexOf('.');
  final first = dot > 0 ? text.substring(0, dot) : text.split('\n').first;
  return first.length <= 60 ? first : '${first.substring(0, 60)}...';
}

String _formatDate(dynamic iso) {
  try {
    if (iso is String) {
      final d = DateTime.tryParse(iso);
      if (d != null) {
        return DateFormat('dd MMMM yyyy, HH:mm').format(d);
      }
    }
  } catch (_) {}
  return '';
}
