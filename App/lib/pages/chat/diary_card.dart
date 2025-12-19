import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'chat_styles.dart';
import 'chat_utils.dart';

class DiaryCard extends StatelessWidget {
  final Map<String, dynamic> entry;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onAdvice;

  const DiaryCard({
    super.key,
    required this.entry,
    required this.isDark,
    required this.onTap,
    required this.onAdvice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: getCardColor(isDark),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [getShadow(isDark)],
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry['formattedDate'] ?? 'No date',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: getTextColor(isDark),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry['title'] ?? titleFromContent(entry['content'] ?? ''),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: onAdvice,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.deepPurple.shade600
                      : Colors.purple.shade500,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.psychology, size: 12, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'Get Advice',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
