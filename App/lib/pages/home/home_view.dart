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
  final VoidCallback? onPrevMonth;
  final VoidCallback? onNextMonth;
  final VoidCallback? onYearTap;
  final int slideDirection;

  const HomeView({
    super.key,
    required this.isDark,
    required this.dd,
    required this.dayWidgets,
    required this.randomSpeech, // <--- 2. CONSTRUCTOR'A EKLE
    this.onPrevMonth,
    this.onNextMonth,
    this.onYearTap,
    this.slideDirection = 0,
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
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 320),
                        reverseDuration: const Duration(milliseconds: 280),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, animation) {
                          final curved = CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                            reverseCurve: Curves.easeInCubic,
                          );
                          final offset = slideDirection > 0
                              ? const Offset(0.35, 0)
                              : slideDirection < 0
                              ? const Offset(-0.35, 0)
                              : const Offset(0.0, 0.0);
                          return FadeTransition(
                            opacity: curved.drive(
                              Tween<double>(begin: 0.0, end: 1.0),
                            ),
                            child: SlideTransition(
                              position: curved.drive(
                                Tween<Offset>(begin: offset, end: Offset.zero),
                              ),
                              child: child,
                            ),
                          );
                        },
                        child: KeyedSubtree(
                          key: ValueKey('${dd.year}-${dd.monthIndex}'),
                          child: CalendarCard(
                            month: dd.month,
                            year: dd.year,
                            isDark: isDark,
                            dayWidgets: dayWidgets,
                            onPrevMonth: onPrevMonth ?? () {},
                            onNextMonth: onNextMonth ?? () {},
                            onYearTap: onYearTap ?? () {},
                          ),
                        ),
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
