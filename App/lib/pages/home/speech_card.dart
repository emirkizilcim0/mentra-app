import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SpeechCard extends StatelessWidget {
  final String speech;
  final String dateStr;
  final bool isDark;

  const SpeechCard({
    super.key,
    required this.speech,
    required this.dateStr,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF2D1B69), const Color(0xFF1A103C)]
                : [const Color(0xFFFFF7F7), const Color(0xFFFDEDED)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black54 : Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_fix_high,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Daily Motivation",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    dateStr,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                speech,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  height: 1.7,
                  color: isDark ? Colors.white : Colors.black87,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
