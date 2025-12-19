// lib/services/diary/diary_helpers.dart
class DiaryHelpers {
  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static String generateTitle(String content) {
    if (content.isEmpty) return 'Untitled Diary';
    final line = content.split('\n').first.trim();
    return line.length <= 30 ? line : '${line.substring(0, 30)}...';
  }

  static String formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final d = DateTime.parse(dateStr);
      return '${_days[d.weekday - 1]}, ${d.day} ${_months[d.month - 1]} ${d.year}';
    } catch (_) {
      return dateStr;
    }
  }
}
