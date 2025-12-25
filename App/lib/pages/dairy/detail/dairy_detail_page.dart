import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:mentra_app/providers/theme_provider.dart';
import 'package:mentra_app/pages/dairy/detail/dairy_content_card.dart';
import 'package:mentra_app/pages/dairy/detail/dairy_helpers.dart';
import 'package:mentra_app/pages/dairy/detail/dairy_styles.dart';

class DiaryDetailPage extends StatelessWidget {
  final Map<String, dynamic> diaryEntry;

  const DiaryDetailPage({super.key, required this.diaryEntry});

  @override
  Widget build(BuildContext context) {
    // ThemeProvider'dan mevcut tema durumunu alıyoruz
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    final title = DiaryHelpers.getTitle(diaryEntry);
    final date = DiaryHelpers.getDate(diaryEntry);
    final content = (diaryEntry['content'] ?? '').toString();

    return Scaffold(
      extendBodyBehindAppBar: true,
      // Scaffold arka plan rengini temaya göre ayarlıyoruz
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFE8F4F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Diary Entry",
          style: GoogleFonts.poppins(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // HATA BURADAYDI: Statik değişken yerine yeni fonksiyonu çağırıyoruz
        decoration: DiaryStyles.getBackground(isDark),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 100, 16, 20),
          child: DiaryContentCard(
            date: date,
            title: title,
            content: content,
            isDark: isDark, // Kart içeriğinin de karanlık olması için ekledik
          ),
        ),
      ),
    );
  }
}
