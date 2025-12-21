// lib/okay_button.dart
import 'package:flutter/material.dart';
import 'package:mentra_app/pages/test/mbti_test_page.dart';
import 'info_theme_colors.dart';

class OkayButton extends StatelessWidget {
  final bool isDark;
  const OkayButton({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MbtiTestPage()),
      ),
      child: Container(
        width: 160,
        height: 55,
        decoration: BoxDecoration(
          color: InfoColors.btn(isDark),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: InfoColors.shadow(isDark),
              offset: const Offset(0, 4),
              blurRadius: 6,
            ),
          ],
        ),
        child: const Center(
          child: Text(
            "Okay",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
