// lib/advice_colors.dart
import 'package:flutter/material.dart';

class AdviceColors {
  static Color bg(bool isDark) =>
      isDark ? const Color(0xFF121212) : const Color(0xFFF7F9FC);

  static Color card(bool isDark) =>
      isDark ? const Color(0xFF1E1E1E) : Colors.white;

  static Color text(bool isDark) => isDark ? Colors.white : Colors.black87;

  static Color shadow(bool isDark) => isDark ? Colors.black54 : Colors.black12;
}
