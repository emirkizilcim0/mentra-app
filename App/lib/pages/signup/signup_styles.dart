import 'package:flutter/material.dart';

class SignupStyles {
  static const BoxDecoration backgroundGradient = BoxDecoration(
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

  static BoxDecoration formContainerDecoration = BoxDecoration(
    color: Colors.white.withOpacity(0.95),
    borderRadius: BorderRadius.circular(30),
    boxShadow: [
      BoxShadow(
        color: Colors.black12.withOpacity(0.05),
        blurRadius: 10,
        spreadRadius: 3,
      ),
    ],
  );

  static InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.grey[700],
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: Colors.grey[300],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
    );
  }
}
