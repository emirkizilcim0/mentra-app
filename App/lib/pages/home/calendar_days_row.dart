import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CalendarDaysRow extends StatelessWidget {
  final bool isDark;
  const CalendarDaysRow({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    const days = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: days
          .map(
            (d) => Text(
              d,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          )
          .toList(),
    );
  }
}
