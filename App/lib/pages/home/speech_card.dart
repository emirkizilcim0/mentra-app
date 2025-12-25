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
    // Ekran boyutlarını alıyoruz
    final size = MediaQuery.of(context).size;
    final double screenWidth = size.width;

    // Dinamik font boyutları
    final double titleFontSize = screenWidth < 360 ? 15 : 17;
    final double textFontSize = screenWidth < 360 ? 13 : 15;
    final double dateFontSize = screenWidth < 360 ? 10 : 11;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 550),
        child: Padding(
          // Ekran kenarlarından güvenli bir boşluk bırakıyoruz
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF231454), const Color(0xFF140B30)]
                    : [const Color(0xFFFFFFFF), const Color(0xFFF8F0FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.black.withOpacity(0.03),
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black45
                      : Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            // Overflow hatasına neden olan IntrinsicHeight kaldırıldı.
            // Column içindeki MainAxisSize.min zaten içeriğe göre boyutu ayarlayacaktır.
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Üst Kısım: İkon ve Başlık
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white10
                              : Colors.deepPurple.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.auto_awesome,
                          color: isDark
                              ? const Color(0xFFA685FF)
                              : Colors.deepPurpleAccent,
                          size: screenWidth < 360 ? 18 : 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Daily Motivation",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: titleFontSize,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. Orta Kısım: Motivasyon Sözü
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Text(
                    speech,
                    textAlign: TextAlign.left,
                    style: GoogleFonts.poppins(
                      fontSize: textFontSize,
                      height: 1.5,
                      color: isDark
                          ? Colors.white.withOpacity(0.9)
                          : Colors.black87.withOpacity(0.85),
                      fontStyle: FontStyle.italic,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),

                // 3. Alt Kısım: Tarih
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 12, 22, 20),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      dateStr,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: dateFontSize,
                        letterSpacing: 0.5,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
