import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TestHeader extends StatelessWidget {
  final bool isDark;
  const TestHeader({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Text(
          "Mentra",
          style: GoogleFonts.pacifico(
            fontSize: 28,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}
