import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mentra_app/pages/dairy/detail/dairy_content_card.dart';
import 'package:mentra_app/pages/dairy/detail/dairy_helpers.dart';
import 'package:mentra_app/pages/dairy/detail/dairy_styles.dart';
// Dosya yollarını proje yapına göre ayarla

class DiaryDetailPage extends StatelessWidget {
  final Map<String, dynamic> diaryEntry;

  const DiaryDetailPage({super.key, required this.diaryEntry});

  @override
  Widget build(BuildContext context) {
    final title = DiaryHelpers.getTitle(diaryEntry);
    final date = DiaryHelpers.getDate(diaryEntry);
    final content = (diaryEntry['content'] ?? '').toString();

    return Scaffold(
      extendBodyBehindAppBar: true, // AppBar'ın arkasına gradient taşsın
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Diary Entry",
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: DiaryStyles.gradientBackground,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            16,
            100,
            16,
            20,
          ), // AppBar için üstten boşluk
          child: DiaryContentCard(date: date, title: title, content: content),
        ),
      ),
    );
  }
}
