import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashStyles {
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

  static TextStyle get logoTextStyle => GoogleFonts.poppins(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: 2,
    shadows: [
      const Shadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
    ],
  );
}
