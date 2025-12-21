import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Tarih formatı için ekledik
import 'package:mentra_app/pages/dairy/detail/dairy_detail_page.dart';
import 'selection_dialog.dart';

class LogicNav {
  static void checkForAutoOpen(
    BuildContext context,
    DateTime? selectedDate,
    List<Map<String, dynamic>> entries,
    bool isDark,
  ) {
    if (selectedDate == null) return;

    // 1. ADIM: Aradığımız tarihi "YYYY-MM-DD" formatına (Yıl-Ay-Gün) çeviriyoruz.
    // Bu format veritabanındaki "2025-12-20T16:..." stringinin başlangıcıyla aynıdır.
    String y = selectedDate.year.toString();
    String m = selectedDate.month.toString().padLeft(2, '0');
    String d = selectedDate.day.toString().padLeft(2, '0');

    String targetKey = "$y-$m-$d"; // Örn: "2025-12-20"

    // 2. ADIM: Listeyi filtreliyoruz (Güvenli Yöntem)
    final dailyEntries = entries.where((e) {
      // Veri null gelirse direkt atla
      if (e['date'] == null) return false;

      // Veriyi string'e çevir (zaten string ama garanti olsun)
      String rawDate = e['date'].toString();

      // "2025-12-20T15:30..." stringi, "2025-12-20" ile başlıyor mu?
      // Veya içeriyor mu? (Boşluk/format hatalarına karşı 'contains' daha güvenli)
      return rawDate.contains(targetKey);
    }).toList();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (dailyEntries.isEmpty) {
        // Kullanıcıya okunabilir tarih göstermek için formatlayalım
        String readableDate = DateFormat('d MMM yyyy').format(selectedDate);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$readableDate için günlük bulunamadı.'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      } else if (dailyEntries.length == 1) {
        // Tek kayıt varsa direkt aç
        openDiaryDetail(context, dailyEntries.first);
      } else {
        // Birden fazla varsa seçim yaptır
        showDiarySelectionPopup(
          context,
          dailyEntries,
          isDark,
          (entry) => openDiaryDetail(context, entry),
        );
      }
    });
  }

  static void openDiaryDetail(
    BuildContext context,
    Map<String, dynamic> entry,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DiaryDetailPage(diaryEntry: entry)),
    );
  }
}
