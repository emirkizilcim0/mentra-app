import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WriteStyles {
  static const BoxDecoration gradientBackground = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFB3E5FC),
        Color(0xFFE1BEE7),
        Color(0xFFFFF9C4),
        Color(0xFFB2DFDB),
      ],
      stops: [0.1, 0.4, 0.7, 0.9],
    ),
  );

  static BoxDecoration cardDecoration = BoxDecoration(
    color: Colors.white.withOpacity(0.95),
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
        color: Colors.black12.withOpacity(0.05),
        blurRadius: 10,
        spreadRadius: 3,
      ),
    ],
  );

  static TextStyle titleStyle = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: Colors.black87,
  );
  static TextStyle contentStyle = GoogleFonts.lato(
    fontSize: 16,
    color: Colors.black87,
    height: 1.7,
  );
  static TextStyle hintStyle = GoogleFonts.poppins(color: Colors.grey.shade500);
}
