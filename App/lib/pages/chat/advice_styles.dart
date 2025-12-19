import 'package:flutter/material.dart';

BoxDecoration cardDecoration(bool isDark) {
  return BoxDecoration(
    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: isDark ? Colors.grey.shade700 : Colors.black12,
      width: 1.5,
    ),
    boxShadow: [
      BoxShadow(
        color: isDark ? Colors.black54 : Colors.black12,
        blurRadius: 6,
        offset: const Offset(0, 3),
      ),
    ],
  );
}

Color getEmojiBgColor(bool isDark) {
  return isDark ? Colors.yellow.shade800 : Colors.yellow.shade200;
}
