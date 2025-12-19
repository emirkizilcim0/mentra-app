import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // Provider paketi
import 'package:mentra_app/providers/theme_provider.dart'; // Senin ThemeProvider dosyanın yolu
import 'package:mentra_app/mbti/result_screen.dart';
import 'package:mentra_app/pages/test/mbti_test_page.dart';

class MbtiSection extends StatelessWidget {
  final String title, desc, type;

  const MbtiSection({
    super.key,
    required this.title,
    required this.desc,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    // 1. ThemeProvider'ı dinliyoruz
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // 2. Renkleri isDark durumuna göre belirliyoruz
    final backgroundColor = isDark
        ? const Color(0xFF1E1E1E)
        : const Color(0xFFFCE4EC);
    final borderColor = isDark ? Colors.white10 : Colors.pink.withOpacity(0.1);
    final primaryTextColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark ? Colors.white70 : Colors.black54;
    final accentColor = const Color(0xFFD68DA8); // Ana tema rengi
    final arrowBgColor = isDark ? Colors.grey[800] : Colors.white;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ÜST KISIM: MBTI TİPİ VE BAŞLIK
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Personality Type",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: secondaryTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    type.isNotEmpty ? type : "Unknown",
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              // Detay ikon butonu
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ResultScreen(mbtiResult: type),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: arrowBgColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // AÇIKLAMA KISMI
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: primaryTextColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            desc.isNotEmpty ? desc : "Tap arrow to see detailed analysis.",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: secondaryTextColor,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 20),

          // RETAKE BUTONU
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MbtiTestPage()),
                );
              },
              icon: const Icon(Icons.refresh, size: 16),
              label: Text(
                "Retake Test",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: accentColor,
                side: BorderSide(color: accentColor),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
