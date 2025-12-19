import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:mentra_app/pages/home/home_page.dart';
import 'package:mentra_app/pages/chat/advice_page.dart';
import 'package:mentra_app/pages/mood/mood_graph_page.dart';

class ProfileBottomNav extends StatelessWidget {
  const ProfileBottomNav({super.key});

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
                  color: isDark
                      ? Colors.white.withOpacity(0.2)
                      : Colors.white.withOpacity(0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _navIcon(
                    context,
                    Icons.home,
                    () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const HomePage()),
                    ),
                  ),
                  _navIcon(
                    context,
                    Icons.lightbulb_outline,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdvicePage()),
                    ),
                  ),
                  _navIcon(
                    context,
                    Icons.emoji_emotions_outlined,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MoodGraphPage()),
                    ),
                  ),
                  _navIcon(context, Icons.person_outline, () {}),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navIcon(BuildContext context, IconData icon, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, color: Theme.of(context).colorScheme.onBackground),
      onPressed: onTap,
    );
  }
}
