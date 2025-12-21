import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // <--- TARİH FORMATI İÇİN EKLENDİ
import 'package:mentra_app/pages/advice/details/advice_details_page.dart';
// Dosya yolunu senin projendeki yerine göre kontrol et:
import 'advice_card.dart';
import 'advice_utils.dart';

class AdviceList extends StatelessWidget {
  final List<Map<String, dynamic>> analyses;
  final bool isDark;

  const AdviceList({super.key, required this.analyses, required this.isDark});

  // --- YARDIMCI FONKSİYON: TARİH FORMATLA ---
  String _formatDate(dynamic dateStr) {
    if (dateStr == null) return "";
    try {
      // Gelen veri zaten DateTime ise direkt al, yoksa String'den çevir
      DateTime date;
      if (dateStr is DateTime) {
        date = dateStr;
      } else {
        // Eğer zaten formatlanmışsa ("20 Dec...") parse hatası verebilir,
        // bu durumda catch bloğuna düşer ve olduğu gibi gösteririz.
        date = DateTime.parse(dateStr.toString());
      }
      // Format: "20 December 2025"
      return DateFormat('d MMMM yyyy', 'en_US').format(date);
    } catch (_) {
      return dateStr.toString();
    }
  }
  // -------------------------------------------

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: analyses.length,
      itemBuilder: (context, index) {
        final item = analyses[index];

        // GÜNCELLEME: Veri 'analysis', 'content' veya 'advice' olarak gelebilir.
        // Hepsini kontrol ediyoruz ki yazı boş kalmasın.
        final adviceText =
            item['analysis']?.toString() ??
            item['content']?.toString() ??
            item['advice']?.toString() ??
            '';

        final title = getTitleFromAdvice(adviceText);
        final mood = item['mood'] ?? 'Calm';
        final emoji = _getEmojiForMood(mood);

        return AdviceCard(
          // --- BURASI GÜNCELLENDİ ---
          // Ham veriyi _formatDate fonksiyonuna sokuyoruz.
          // Hangisi doluysa onu alıp formatlayacak.
          date: _formatDate(
            item['formattedDate'] ?? item['created_at'] ?? item['date'],
          ),

          title: title,
          mood: mood,
          emoji: emoji,
          isDark: isDark,
          // SAYFA YÖNLENDİRMESİ BURADA
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AdviceDetailPage(
                  analysisItem: item, // Tüm veriyi detay sayfasına gönderiyoruz
                  title: title,
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _getEmojiForMood(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return '😊';
      case 'sad':
        return '😢';
      case 'anxious':
        return '😰';
      case 'angry':
        return '😠';
      case 'calm':
        return '😌';
      case 'confused':
        return '😕';
      default:
        return '😊';
    }
  }
}
