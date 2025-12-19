// lib/comp_date.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'advice_colors.dart';

class CompDate extends StatelessWidget {
  final String date;
  final bool isDark;

  const CompDate({required this.date, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            date,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AdviceColors.text(isDark),
            ),
          ),
        ),
      ],
    );
  }
}
