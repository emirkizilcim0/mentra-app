// lib/comp_body.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'advice_colors.dart';

class CompBody extends StatelessWidget {
  final String text;
  final bool isDark;

  const CompBody({required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 14,
        color: AdviceColors.text(isDark),
      ),
    );
  }
}
