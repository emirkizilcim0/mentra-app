import 'package:flutter/material.dart';

class MoodGraphStyles {
  static LinearGradient getBackground(bool isDark) {
    return isDark
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF121212), Color(0xFF1E1E1E)],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF7F9FC), Color(0xFFFFFFFF)],
          );
  }

  static Color getLineColor(bool isDark) =>
      isDark ? const Color(0xFF80CBC4) : const Color(0xFF26A69A);
  static Color getGridColor(bool isDark) =>
      isDark ? Colors.white10 : Colors.black12;
  static Color getTextColor(bool isDark) =>
      isDark ? Colors.white : Colors.black87;

  static BoxDecoration getChartContainerDecoration(bool isDark) {
    return BoxDecoration(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: isDark ? Colors.black54 : Colors.black12,
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
