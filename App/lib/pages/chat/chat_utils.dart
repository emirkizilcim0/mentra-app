String getWeekday(int weekday) {
  const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return weekdays[weekday - 1];
}

String getMonth(int month) {
  const months = [
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
  return months[month - 1];
}

String titleFromContent(String content) {
  final text = content.trim();
  if (text.isEmpty) return 'Untitled';
  final dot = text.indexOf('.');
  final first = dot > 0 ? text.substring(0, dot) : text.split('\n').first;
  return first.length <= 60 ? first : '${first.substring(0, 60)}...';
}

String formatDateForComparison(DateTime date) {
  final weekday = getWeekday(date.weekday);
  final month = getMonth(date.month);
  return '$weekday, ${date.day} $month ${date.year}';
}
