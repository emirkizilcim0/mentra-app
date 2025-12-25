import 'package:flutter/material.dart';

class DiaryStyles {
  // --- DINAMIK ARKA PLAN ---
  static BoxDecoration getBackground(bool isDark) {
    return BoxDecoration(
      gradient: isDark
          ? const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0F0F0F), // Çok koyu gri/siyah
                Color(0xFF1A1A2E), // Koyu lacivert tonu
                Color(0xFF16213E), // Derin gece mavisi
                Color(0xFF0F0F0F),
              ],
              stops: [0.1, 0.4, 0.7, 0.9],
            )
          : const LinearGradient(
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
  }

  // --- DINAMIK KART DEKORASYONU ---
  static BoxDecoration getCardDecoration(bool isDark) {
    return BoxDecoration(
      // Karanlık modda kart rengini daha koyu ve cam efekti (glassmorphism) veriyoruz
      color: isDark
          ? Colors.black.withOpacity(0.5)
          : Colors.white.withOpacity(0.95),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: isDark
            ? Colors.white.withOpacity(0.1)
            : Colors.white.withOpacity(0.5),
      ),
      boxShadow: [
        BoxShadow(
          color: isDark ? Colors.black26 : Colors.black12.withOpacity(0.05),
          blurRadius: 10,
          spreadRadius: 3,
        ),
      ],
    );
  }
}
