import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdviceTheme {
  final bool isDark;

  AdviceTheme(this.isDark);

  Color get background =>
      isDark ? const Color(0xFF121212) : const Color(0xFFF7F9FC);

  Color get card => isDark ? const Color(0xFF1E1E1E) : Colors.white;

  Color get text => isDark ? Colors.white : Colors.black87;

  Color get shadow => isDark ? Colors.black54 : Colors.black12;

  TextStyle get dateStyle => GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: text,
  );

  TextStyle get titleStyle => GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: text,
  );

  TextStyle get bodyStyle => GoogleFonts.poppins(fontSize: 14, color: text);
}
