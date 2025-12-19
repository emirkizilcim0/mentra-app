import 'package:flutter/material.dart';

Color getCardColor(bool isDark) {
  return isDark ? const Color(0xFF1E1E1E) : Colors.white;
}

Color getTextColor(bool isDark) {
  return isDark ? Colors.white : Colors.black87;
}

BoxShadow getShadow(bool isDark) {
  return BoxShadow(
    color: isDark ? Colors.black.withOpacity(0.5) : Colors.black12,
    blurRadius: 4,
    offset: const Offset(0, 2),
  );
}
