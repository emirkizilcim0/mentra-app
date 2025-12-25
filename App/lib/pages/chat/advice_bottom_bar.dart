import 'package:flutter/material.dart';
import 'package:mentra_app/pages/home/home_page.dart';
import 'package:mentra_app/pages/mood/mood_graph_page.dart';
import 'package:mentra_app/pages/profile/profile_page.dart';
import 'dart:ui';

class AdviceBottomBar extends StatelessWidget {
  final bool isDark;
  const AdviceBottomBar({super.key, required this.isDark});

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
                color: (isDark ? Colors.black : Colors.white).withOpacity(0.3),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white.withOpacity(isDark ? 0.2 : 0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _navIcon(
                    context,
                    Icons.home_outlined,
                    Icons.home,
                    false,
                    () => Navigator.pushNamed(context, '/home'),
                  ),
                  // ADVICE İKONU (Aktif Sayfa)
                  _navIcon(
                    context,
                    Icons.lightbulb_outline,
                    Icons.lightbulb,
                    true, // ŞİMDİ AKTİF
                    () {}, // Zaten buradayız
                  ),
                  _navIcon(
                    context,
                    Icons.emoji_emotions_outlined,
                    Icons.emoji_emotions,
                    false,
                    () => Navigator.pushNamed(context, '/moodGraph'),
                  ),
                  _navIcon(
                    context,
                    Icons.person_outline,
                    Icons.person,
                    false,
                    () => Navigator.pushNamed(context, '/profile'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navIcon(
    BuildContext context,
    IconData outlineIcon,
    IconData solidIcon,
    bool isActive,
    VoidCallback onTap,
  ) {
    return IconButton(
      icon: Icon(
        isActive ? solidIcon : outlineIcon,
        // Aktif ikon tam opak, diğerleri %60 opak
        color: (isDark ? Colors.white : Colors.black87).withOpacity(
          isActive ? 1.0 : 0.6,
        ),
        size: isActive ? 28 : 24,
      ),
      onPressed: onTap,
    );
  }
}
