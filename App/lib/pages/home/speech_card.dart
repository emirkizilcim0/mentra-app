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
    // 1. Ekran boyutunu alıyoruz
    final size = MediaQuery.of(context).size;

    // 2. Ekran genişliğine göre dinamik padding hesaplıyoruz
    // Ekranın %5'i kadar yanlardan boşluk bırakır.
    final double sidePadding = size.width * 0.05;

    // İçerik için de ekranın boyutuna göre biraz esneklik tanıyoruz
    // Küçük ekranlarda (örn: 350px altı) yazı boyutu bir tık küçülebilir
    final double titleFontSize = size.width < 350 ? 16 : 18;
    final double textFontSize = size.width < 350 ? 14 : 16;

    return Center(
      // Geniş ekranlarda (tablet) kartı ortalamak için
      child: ConstrainedBox(
        // 3. Tablet/Masaüstü önlemi: Kart asla 600 pixelden geniş olmasın.
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          // Dış kenar boşlukları (Dinamik)
          padding: EdgeInsets.symmetric(horizontal: sidePadding, vertical: 12),
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
                  // Kartın içindeki ikon ve başlık kısmı
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(
                        Icons.auto_fix_high,
                        color: isDark ? Colors.white : Colors.black87,
                        // İkon boyutu da çok küçük ekranlarda küçülsün
                        size: size.width < 350 ? 20 : 24,
                      ),
                      const SizedBox(width: 8),
                      // Başlık taşarsa "..." koysun diye Flexible ekledik
                      Flexible(
                        child: Text(
                          "Daily Motivation",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: titleFontSize,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis, // Sığmazsa üç nokta
                        ),
                      ),
                    ],
                  ),
                ),

                // Sözün kendisi
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    speech,
                    style: GoogleFonts.poppins(
                      fontSize: textFontSize,
                      height:
                          1.6, // Satır arası boşluk okunabilirlik için iyidir
                      color: isDark ? Colors.white : Colors.black87,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

                // Tarih kısmı (En altta sağda şık durur)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      dateStr,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w400,
                        fontSize: 12, // Tarih biraz daha küçük ve zarif
                        color: isDark ? Colors.white54 : Colors.black45,
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
