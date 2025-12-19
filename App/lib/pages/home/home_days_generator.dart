// lib/pages/home/home_days_generator.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'home_date_data.dart';
import 'calendar_day_cell.dart';
import 'color_utils.dart';

class HomeDaysGenerator {
  static List<Widget> generate({
    required HomeDateData dd,
    required Map<String, int> percents,
    required Map<String, String> days,
    required bool isDark,
    required Function(int, int, int) onDayTap,
  }) {
    return List.generate(dd.blankSpaces + dd.lastDayOfMonth, (i) {
      if (i < dd.blankSpaces) return const SizedBox(width: 38, height: 38);

      final day = i + 1 - dd.blankSpaces;
      final key = DateFormat(
        'yyyy-MM-dd',
      ).format(DateTime(dd.year, dd.monthIndex + 1, day));

      return CalendarDayCell(
        day: day,
        isToday: day == dd.now.day,
        isDark: isDark,
        fillColor: percents[key] != null
            ? fillForPercent(percents[key]!, isDark)
            : null,
        onTap: days[key] != null
            ? () => onDayTap(day, dd.monthIndex, dd.year)
            : null,
      );
    });
  }
}
