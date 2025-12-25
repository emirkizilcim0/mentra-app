// lib/pages/home/home_view.dart
import 'package:flutter/material.dart';
import 'top_bar.dart';
import 'calendar_card.dart';
import 'speech_card.dart';
import 'home_bottom_nav.dart';
import 'home_date_data.dart';

class HomeView extends StatelessWidget {
  final bool isDark;
  final HomeDateData dd;
  final List<Widget> dayWidgets;
  final String randomSpeech;
  final VoidCallback? onPrevMonth;
  final VoidCallback? onNextMonth;
  final VoidCallback? onYearTap;
  final int slideDirection;
  final bool showNextButton; // <--- GELECEK AY KONTROLÜ İÇİN EKLENDİ

  const HomeView({
    super.key,
    required this.isDark,
    required this.dd,
    required this.dayWidgets,
    required this.randomSpeech,
    required this.showNextButton, // <--- CONSTRUCTOR'A EKLENDİ
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
                            showNextButton:
                                showNextButton, // <--- CARD'A İLETİLDİ
                          ),
                        ),
                      ),
                      SpeechCard(
                        speech: randomSpeech,
                        isDark: isDark,
                        dateStr: _getRealTodayString(),
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

  String _getRealTodayString() {
    final now = DateTime.now();
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return "${months[now.month - 1]} ${now.day}, ${now.year}";
  }
}
