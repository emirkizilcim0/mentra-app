import 'package:flutter/material.dart';

import 'package:mentra_app/pages/home/home_page.dart';
import 'package:mentra_app/pages/mood/mood_graph_page.dart';
import 'package:mentra_app/pages/profile/profile_page.dart';

import 'dart:ui';

import 'advice_page.dart';

class ChatBottomNav extends StatelessWidget {
  final bool isDark;
  const ChatBottomNav({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
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
                  IconButton(
                    icon: Icon(
                      Icons.home,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const HomePage()),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.lightbulb_outline,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdvicePage()),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.emoji_emotions_outlined,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MoodGraphPage()),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.person_outline,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    onPressed: () => Navigator.push(
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
