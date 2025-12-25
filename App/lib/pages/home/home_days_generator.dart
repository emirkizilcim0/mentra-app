// lib/pages/home/home_days_generator.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'home_date_data.dart';
import 'calendar_day_cell.dart';

class HomeDaysGenerator {
  static List<Widget> generate({
    required HomeDateData dd,
    required Map<String, int> percents,
    required Map<String, String> days,
    required bool isDark,
    required Function(int, int, int) onDayTap,
  }) {
    // Gerçek zamanı bir kez alıyoruz
    final DateTime now = DateTime.now();

    return List.generate(dd.blankSpaces + dd.lastDayOfMonth, (i) {
      if (i < dd.blankSpaces) return const SizedBox(width: 38, height: 38);

      final day = i + 1 - dd.blankSpaces;

      // --- DÜZELTME 1: Ay Indeksi ---
      // DateTime ay bilgisini 1'den başlatır.
      // dd.monthIndex 0 ise (Ocak), DateTime içine 1 göndermeliyiz.
      final int currentMonthForDateTime = dd.monthIndex + 1;

      // O günün "yyyy-MM-dd" formatındaki key'ini oluştur
      final key = DateFormat(
        'yyyy-MM-dd',
      ).format(DateTime(dd.year, currentMonthForDateTime, day));

      // --- DÜZELTME 2: isToday Kontrolü ---
      // dd.monthIndex (0-11) olduğu için now.month (1-12) ile karşılaştırırken 1 ekliyoruz.
      bool isToday =
          day == now.day &&
          currentMonthForDateTime == now.month &&
          dd.year == now.year;

      final bool hasEntry = days[key] != null;

      // --- RENK MANTIĞI ---
      Color? boxColor;
      if (hasEntry) {
        if (isToday) {
          boxColor = isDark
              ? const Color.fromARGB(129, 123, 31, 162)
              : const Color.fromARGB(255, 105, 75, 142);
        } else {
          boxColor = isDark
              ? const Color(0xFF4A148C).withOpacity(0.5)
              : const Color(0xFFE1BEE7);
        }
      }

      return CalendarDayCell(
        day: day,
        isToday: isToday,
        isDark: isDark,
        fillColor: boxColor,
        // onDayTap gönderirken dd.monthIndex'i orijinal haliyle bırakıyoruz
        // çünkü HomePage içindeki mantığın 0-11 beklediğini varsayıyoruz.
        onTap: hasEntry ? () => onDayTap(day, dd.monthIndex, dd.year) : null,
      );
    });
  }
}
