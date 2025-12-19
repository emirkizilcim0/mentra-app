import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MbtiResultCard extends StatelessWidget {
  final String title;
  final String desc;
  final bool isDark;

  const MbtiResultCard({
    super.key,
    required this.title,
    required this.desc,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF6A1B9A), const Color(0xFF4A148C)]
              : [const Color(0xFFE1BEE7), const Color(0xFFCE93D8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black45 : Colors.grey.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Personality Type",
            style: GoogleFonts.poppins(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (desc.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              desc,
              style: GoogleFonts.poppins(
                color: isDark ? Colors.white70 : Colors.black87,
                fontSize: 14,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
