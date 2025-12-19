import 'package:flutter/material.dart';

class DetailsStyles {
  static const BoxDecoration gradientBackground = BoxDecoration(
    gradient: LinearGradient(
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

  static BoxDecoration cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: const [
      BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
    ],
  );
}
