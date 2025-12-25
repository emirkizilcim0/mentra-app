import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:mentra_app/pages/chat/advice_page.dart';
import 'package:mentra_app/pages/mood/mood_graph_page.dart';
import 'package:mentra_app/pages/profile/profile_page.dart';

import 'nav_button.dart';

class HomeBottomNav extends StatelessWidget {
  final bool isDark;

  const HomeBottomNav({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.2)
                      : Colors.white.withOpacity(0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  NavButton(icon: Icons.home, isDark: isDark, onTap: () {}),
                  NavButton(
                    icon: Icons.lightbulb_outline,
                    isDark: isDark,
                    // NavButton onTap içinde AdvicePage için:
                    onTap: () {
                      // Eğer zaten AdvicePage'deysek hiçbir şey yapma veya sayfayı yenile
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AdvicePage()),
                      );
                    },
                  ),
                  NavButton(
                    icon: Icons.emoji_emotions_outlined,
                    isDark: isDark,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MoodGraphPage()),
                    ),
                  ),
                  NavButton(
                    icon: Icons.person_outline,
                    isDark: isDark,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfilePage()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
