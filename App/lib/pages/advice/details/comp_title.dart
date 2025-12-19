// lib/comp_title.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'advice_colors.dart';

class CompTitle extends StatelessWidget {
  final String title;
  final bool isDark;

  const CompTitle({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AdviceColors.text(isDark),
      ),
    );
  }
}
