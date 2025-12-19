import 'package:flutter/material.dart';

class NextButtonStyle {
  static BoxDecoration getDecoration(bool isSelected, bool isDark) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(30),
      // Seçiliyse Pembe Gradient, değilse Gri
      gradient: isSelected
          ? const LinearGradient(
              colors: [Color(0xFFE91E63), Color(0xFFF06292)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            )
          : null,
      color: isSelected
          ? null
          : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
    );
  }

  static TextStyle getTextStyle(bool isSelected, bool isDark) {
    return TextStyle(
      // Seçiliyse Beyaz yazı, değilse Gri yazı
      color: isSelected
          ? Colors.white
          : (isDark ? Colors.grey[400] : Colors.black54),
      fontWeight: FontWeight.bold,
      fontSize: 18,
    );
  }
}
