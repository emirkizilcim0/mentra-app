// lib/pages/home/home_days_generator.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'home_date_data.dart';
import 'calendar_day_cell.dart';
// import 'color_utils.dart'; // Artık eski renk mantığına ihtiyacımız kalmadı

class HomeDaysGenerator {
  static List<Widget> generate({
    required HomeDateData dd,
    required Map<String, int> percents,
    required Map<String, String> days,
    required bool isDark,
    required Function(int, int, int) onDayTap,
  }) {
    return List.generate(dd.blankSpaces + dd.lastDayOfMonth, (i) {
      // Boşlukları atla
      if (i < dd.blankSpaces) return const SizedBox(width: 38, height: 38);

      final day = i + 1 - dd.blankSpaces;

      // O günün "yyyy-MM-dd" formatındaki key'ini oluştur
      final key = DateFormat(
        'yyyy-MM-dd',
      ).format(DateTime(dd.year, dd.monthIndex + 1, day));

      // Kontroller
      final bool isToday = (day == dd.now.day);
      final bool hasEntry = days[key] != null; // O güne ait yazı var mı?

      // --- YENİ RENK MANTIĞI ---
      Color? boxColor;

      if (hasEntry) {
        if (isToday) {
          // BUGÜN + YAZI VAR -> Koyu Mor (Vurgulu)
          boxColor = isDark
              ? const Color.fromARGB(
                  129,
                  123,
                  31,
                  162,
                ) // Dark Mode: Canlı Koyu Mor
              : const Color.fromARGB(
                  255,
                  105,
                  75,
                  142,
                ); // Light Mode: En Koyu Mor
        } else {
          // SADECE YAZI VAR -> Açık/Normal Mor
          boxColor = isDark
              ? const Color(0xFF4A148C).withOpacity(
                  0.5,
                ) // Dark Mode: Transparan Koyu
              : const Color(
                  0xFFE1BEE7,
                ); // Light Mode: Tatlı Açık Mor (Lavender)
        }
      } else {
        // Yazı yoksa renk yok (CalendarDayCell kendi varsayılanını kullanır)
        boxColor = null;
      }
      // -------------------------

      return CalendarDayCell(
        day: day,
        isToday: isToday,
        isDark: isDark,
        // Eski fillForPercent yerine hesapladığımız 'boxColor'ı veriyoruz
        fillColor: boxColor,
        onTap: hasEntry ? () => onDayTap(day, dd.monthIndex, dd.year) : null,
      );
    });
  }
}
