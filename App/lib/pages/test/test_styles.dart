import 'package:flutter/material.dart';

class TestStyles {
  static LinearGradient getBackgroundGradient(bool isDark) {
    return isDark
        ? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF121212), Color(0xFF1E1E1E)],
          )
        : const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.fromARGB(39, 253, 253, 253), Color(0xFFFFFFFF)],
          );
  }

  static BoxDecoration cardDecoration(bool isDark) {
    return BoxDecoration(
      color: isDark
          ? const Color(0xFF1E1E1E)
          : const Color.fromARGB(19, 229, 229, 230),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? Colors.black.withOpacity(0.5)
              : const Color.fromARGB(31, 85, 0, 145),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }
}
