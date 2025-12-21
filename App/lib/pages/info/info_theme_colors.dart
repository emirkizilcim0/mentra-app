// lib/info_theme_colors.dart
import 'package:flutter/material.dart';

class InfoColors {
  static Color bg(bool dark) =>
      dark ? const Color(0xFF121212) : const Color(0xFFF9FAFB);

  static Color btn(bool dark) =>
      dark ? const Color(0xFFD68DA8) : const Color(0xFFB36A7A);

  static Color text(bool dark) => dark ? Colors.white : Colors.black87;

  static Color shadow(bool dark) =>
      dark ? Colors.black.withOpacity(0.5) : Colors.black26;

  static Color divider(bool dark) =>
      dark ? Colors.grey.shade600 : Colors.grey.shade400;

  static Color hint(bool dark) =>
      dark ? Colors.grey.shade400 : Colors.grey.shade600;
}
