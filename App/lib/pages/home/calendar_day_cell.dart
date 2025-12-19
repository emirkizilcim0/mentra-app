import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CalendarDayCell extends StatelessWidget {
  final int day;
  final bool isToday;
  final bool isDark;
  final Color? fillColor;
  final VoidCallback? onTap;

  const CalendarDayCell({
    super.key,
    required this.day,
    required this.isToday,
    required this.isDark,
    this.fillColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color:
              fillColor ??
              (isToday
                  ? const Color(0xFFB3E5FC)
                  : (isDark ? const Color(0xFF2D2D2D) : Colors.white)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? Colors.grey.withOpacity(0.5) : Colors.black26,
            width: 1,
          ),
        ),
        child: Text(
          "$day",
          style: GoogleFonts.poppins(
            fontWeight: isToday ? FontWeight.bold : FontWeight.w400,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}
