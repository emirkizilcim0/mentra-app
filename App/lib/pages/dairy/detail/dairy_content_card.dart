import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mentra_app/pages/dairy/detail/dairy_styles.dart';

class DiaryContentCard extends StatelessWidget {
  final String date;
  final String title;
  final String content;
  final bool isDark;

  const DiaryContentCard({
    super.key,
    required this.date,
    required this.title,
    required this.content,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      // HATA BURADAYDI: Fonksiyonu çağırıyoruz ve isDark parametresini gönderiyoruz
      decoration: DiaryStyles.getCardDecoration(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            date,
            style: GoogleFonts.poppins(
              fontSize: 13,
              // Tarih rengi: Koyu modda daha açık gri, açık modda daha koyu gri
              color: isDark ? Colors.grey[400] : Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              // Başlık rengi: Koyu modda beyaz, açık modda siyahımsı
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            content,
            style: GoogleFonts.lato(
              fontSize: 16,
              // İçerik rengi: Koyu modda beyazımsı, açık modda siyahımsı
              color: isDark ? Colors.white70 : Colors.black87,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
