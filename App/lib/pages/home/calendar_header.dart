import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CalendarHeader extends StatelessWidget {
  final String month;
  final int year;
  final bool isDark;

  const CalendarHeader({
    super.key,
    required this.month,
    required this.year,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          month,
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        Text(
          "$year",
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
      ],
    );
  }
}
