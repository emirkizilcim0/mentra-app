import 'package:intl/intl.dart';

class DiaryHelpers {
  static String getTitle(Map<String, dynamic> entry) {
    if (entry['title'] != null && entry['title'].toString().isNotEmpty) {
      return entry['title'].toString();
    }
    final content = (entry['content'] ?? '').toString().trim();
    if (content.isEmpty) return 'Untitled';
    final dotIndex = content.indexOf('.');
    final firstLine = dotIndex > 0
        ? content.substring(0, dotIndex)
        : content.split('\n').first;
    return firstLine.length <= 60
        ? firstLine
        : '${firstLine.substring(0, 60)}...';
  }

  static String getDate(Map<String, dynamic> entry) {
    if (entry['formattedDate'] != null)
      return entry['formattedDate'].toString();
    try {
      final d = DateTime.tryParse(entry['date'].toString());
      if (d != null) return DateFormat('dd MMMM yyyy, HH:mm').format(d);
    } catch (_) {}
    return '';
  }

  static formatDate(diary) {}

  static generateTitle(diary) {}
}
