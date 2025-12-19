// lib/top_bar_section.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'info_theme_colors.dart';

class TopBarSection extends StatelessWidget {
  final bool isDark;
  const TopBarSection({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FloatingActionButton.extended(
              heroTag: 'mentraTitle',
              onPressed: () {},
              backgroundColor: Colors.transparent,
              elevation: 0,
              label: Text(
                "Mentra",
                style: GoogleFonts.pacifico(
                  fontSize: 28,
                  color: InfoColors.text(isDark),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
