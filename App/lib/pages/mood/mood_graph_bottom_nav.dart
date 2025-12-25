import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mentra_app/pages/chat/advice_page.dart';
import 'package:mentra_app/pages/home/home_page.dart';
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
                color: (isDark ? Colors.black : Colors.white).withOpacity(0.3),
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
                    Icons.home_outlined,
                    isDark,
                    () => Navigator.pushNamed(context, '/home'),
                  ),
                  _icon(
                    context,
                    Icons.lightbulb_outline,
                    isDark,
                    () => Navigator.pushNamed(context, '/advice'),
                  ),
                  // Aktif ikon (Emoji) dolu olanıyla değiştirilebilir
                  _icon(context, Icons.emoji_emotions, isDark, () {}),
                  _icon(
                    context,
                    Icons.person_outline,
                    isDark,
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

  Widget _icon(BuildContext c, IconData i, bool isDark, VoidCallback f) =>
      IconButton(
        icon: Icon(i, color: isDark ? Colors.white : Colors.black87),
        onPressed: f,
      );
}
