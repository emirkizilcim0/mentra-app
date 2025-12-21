// lib/pages/home/home_view.dart
import 'package:flutter/material.dart';
// motivational_speeches importuna artık burada ihtiyacın kalmadı ama durabilir
import 'top_bar.dart';
import 'calendar_card.dart';
import 'speech_card.dart';
import 'home_bottom_nav.dart';
import 'home_date_data.dart';

class HomeView extends StatelessWidget {
  final bool isDark;
  final HomeDateData dd;
  final List<Widget> dayWidgets;
  final String randomSpeech; // <--- 1. BU DEĞİŞKENİ EKLE

  const HomeView({
    super.key,
    required this.isDark,
    required this.dd,
    required this.dayWidgets,
    required this.randomSpeech, // <--- 2. CONSTRUCTOR'A EKLE
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFE8F4F9),
      body: Stack(
        children: [
          Column(
            children: [
              HomeTopBar(isDark: isDark),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 90),
                  child: Column(
                    children: [
                      CalendarCard(
                        month: dd.month,
                        year: dd.year,
                        isDark: isDark,
                        dayWidgets: dayWidgets,
                      ),
                      // 3. BURADAKİ DEĞİŞİKLİĞE DİKKAT
                      SpeechCard(
                        speech:
                            randomSpeech, // Artık listeden değil, gelen tek sözü kullanıyoruz
                        isDark: isDark,
                        dateStr: "${dd.month} ${dd.now.day}, ${dd.year}",
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          HomeBottomNav(isDark: isDark),
        ],
      ),
    );
  }
}
