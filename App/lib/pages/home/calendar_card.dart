import 'package:flutter/material.dart';
import 'calendar_header.dart';
import 'calendar_days_row.dart';

class CalendarCard extends StatelessWidget {
  final String month;
  final int year;
  final bool isDark;
  final List<Widget> dayWidgets;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onYearTap;
  final bool showNextButton; // HomePage'den gelecek kontrol

  const CalendarCard({
    super.key,
    required this.month,
    required this.year,
    required this.isDark,
    required this.dayWidgets,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.onYearTap,
    required this.showNextButton,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.grey.withOpacity(0.3) : Colors.black12,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          CalendarHeader(
            month: month,
            year: year,
            isDark: isDark,
            onYearTap: onYearTap,
            onPrevMonth: onPrevMonth,
            onNextMonth: onNextMonth,
            showNextButton: showNextButton,
          ),
          const SizedBox(height: 10),
          CalendarDaysRow(isDark: isDark),
          const SizedBox(height: 10),
          Wrap(spacing: 10, runSpacing: 10, children: dayWidgets),
        ],
      ),
    );
  }
}
