import 'package:flutter/material.dart';

class AnswerData {
  static const List<double> sizes = [50.0, 40.0, 30.0, 40.0, 50.0];

  static const List<Color> colors = [
    Color(0xFFD32F2F), // Koyu Kırmızı (disagree)
    Color(0xFFFFCDD2), // Açık Kırmızı
    Color(0xFF989898), // Nötr
    Color(0xFFC8E6C9), // Açık Yeşil
    Color(0xFF388E3C), // Koyu Yeşil (agree)
  ];

  static Color getColor(int index) => colors[index];
  static double getSize(int index) => sizes[index];
}
