import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mentra_app/pages/home/home_page.dart';
import 'package:mentra_app/pages/chat/advice_page.dart';
import 'package:mentra_app/pages/profile/profile_page.dart';

class MoodGraphBottomNav extends StatelessWidget {
  const MoodGraphBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                  color: Colors.white.withOpacity(isDark ? 0.2 : 0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _icon(
                    context,
                    Icons.home,
                    () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const HomePage()),
                    ),
                  ),
                  _icon(
                    context,
                    Icons.lightbulb_outline,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdvicePage()),
                    ),
                  ),
                  _icon(
                    context,
                    Icons.emoji_emotions_outlined,
                    () {},
                  ), // Zaten bu sayfadayız
                  _icon(
                    context,
                    Icons.person_outline,
                    () => Navigator.push(
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

  Widget _icon(BuildContext c, IconData i, VoidCallback f) => IconButton(
    icon: Icon(i, color: Theme.of(c).colorScheme.onBackground),
    onPressed: f,
  );
}
