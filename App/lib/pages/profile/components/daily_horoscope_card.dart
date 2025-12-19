// lib/pages/profile/components/daily_horoscope_card.dart
import 'package:flutter/material.dart';
import 'package:mentra_app/services/local_horoscope_service.dart';

class DailyHoroscopeCard extends StatelessWidget {
  final String
  userSign; // Örn: "Aries", "Taurus" (CSV başlıklarıyla aynı olmalı)
  final bool isDark;

  const DailyHoroscopeCard({
    super.key,
    required this.userSign,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // Tema renkleri
    final textColor = isDark ? Colors.white : Colors.black87;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final shadowColor = isDark ? Colors.black45 : Colors.grey.withOpacity(0.2);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24), // Yuvarlak hatlar
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: isDark ? Border.all(color: Colors.white10, width: 1) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Başlık Kısmı ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.deepPurpleAccent,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Günlük Burç Yorumu",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      Text(
                        userSign, // Kullanıcının burcu (Örn: Scorpio)
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.deepPurpleAccent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Opsiyonel: Paylaş butonu veya tarih ikonu eklenebilir
              Icon(
                Icons.calendar_today_outlined,
                color: textColor.withOpacity(0.3),
                size: 18,
              ),
            ],
          ),

          const SizedBox(height: 20),
          Divider(color: textColor.withOpacity(0.1), height: 1),
          const SizedBox(height: 20),

          // --- İçerik Kısmı (FutureBuilder) ---
          FutureBuilder<String>(
            future: LocalHoroscopeService.getDailyMessage(userSign),
            builder: (context, snapshot) {
              // 1. Yükleniyor durumu
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(
                      color: Colors.deepPurpleAccent,
                      strokeWidth: 2,
                    ),
                  ),
                );
              }

              // 2. Hata durumu
              if (snapshot.hasError) {
                return Text(
                  "Yorum yüklenirken bir hata oluştu.",
                  style: TextStyle(color: Colors.redAccent),
                );
              }

              // 3. Veri gösterimi
              return Text(
                snapshot.data ?? "Bugün için yorum bulunamadı.",
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6, // Satır aralığı okunabilirlik için önemli
                  color: textColor.withOpacity(0.9),
                  fontFamily: 'Roboto', // Varsa özel fontun
                  fontStyle: FontStyle.normal,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
