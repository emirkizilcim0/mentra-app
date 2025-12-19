import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // 1. Provider paketini ekledik
import 'package:mentra_app/providers/theme_provider.dart'; // 2. ThemeProvider'ı import ettik
import 'package:mentra_app/mbti/personality_data.dart';
import 'package:mentra_app/pages/home/home_page.dart';

class ResultScreen extends StatelessWidget {
  final String mbtiResult;

  const ResultScreen({super.key, required this.mbtiResult});

  @override
  Widget build(BuildContext context) {
    // 3. ThemeProvider'dan mevcut tema durumunu alıyoruz
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final data = personalityData[mbtiResult];
    final title = data?.title ?? "Unknown Type";
    final description = data?.description ?? "No description available.";

    // 4. Renkleri dinamik olarak belirliyoruz
    final backgroundColor = isDark
        ? const Color(0xFF121212)
        : const Color(0xFFFDF2F8);
    final primaryTextColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark ? Colors.white70 : Colors.grey;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final descriptionBoxColor = isDark
        ? Colors.pink[900]!.withOpacity(0.2)
        : const Color(0xFFFFE4E6);
    final circleTextColor = isDark
        ? const Color(0xFFD68DA8)
        : Colors.deepPurple;
    final buttonColor = isDark ? Colors.grey[800] : Colors.grey[300];

    return Scaffold(
      backgroundColor: backgroundColor,
      // --- AppBar Kısmı ---
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 24,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Mentra",
              style: GoogleFonts.pacifico(
                fontSize: 28,
                color: primaryTextColor, // Dinamik renk
              ),
            ),
            Text(
              "Test Result",
              style: TextStyle(
                color: secondaryTextColor, // Dinamik renk
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),

      // --- Body Kısmı ---
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              // MBTI Sonuç Kutusu (Daire)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor, // Dinamik renk
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black45 : Colors.black12,
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Text(
                  mbtiResult,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: circleTextColor, // Dinamik renk
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Başlık
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor, // Dinamik renk
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Açıklama Kutusu
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: descriptionBoxColor, // Dinamik renk
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  description,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: primaryTextColor, // Dinamik renk
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 40),

              // Continue Butonu
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor, // Dinamik renk
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  "Continue ->",
                  style: TextStyle(color: primaryTextColor), // Dinamik renk
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
