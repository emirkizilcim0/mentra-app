import 'package:intl/intl.dart';

class HomeDateData {
  final DateTime now;
  late final String month;
  late final int year;
  late final int monthIndex;
  late final int lastDayOfMonth;
  late final int blankSpaces;
  late final int speechIndex;

  HomeDateData(this.now, int totalSpeeches) {
    month = DateFormat.MMMM().format(now);
    year = now.year;
    monthIndex = now.month - 1;

    final firstDay = DateTime(year, now.month, 1);
    lastDayOfMonth = DateTime(year, now.month + 1, 0).day;
    blankSpaces = firstDay.weekday % 7;

    final dayOfYear = int.parse(DateFormat("D").format(now));
    speechIndex = dayOfYear % totalSpeeches;
  }
}
