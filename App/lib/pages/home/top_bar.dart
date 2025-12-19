import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mentra_app/pages/chat/chat_page.dart';

class HomeTopBar extends StatelessWidget {
  final bool isDark;
  const HomeTopBar({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FloatingActionButton.extended(
              heroTag: 'mentraTitle',
              onPressed: () {},
              backgroundColor: Colors.transparent,
              elevation: 0,
              label: Text(
                "Mentra",
                style: GoogleFonts.pacifico(
                  fontSize: 28,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            FloatingActionButton(
              heroTag: 'chatButtonTop',
              mini: true,
              shape: const CircleBorder(),
              elevation: 2.0,
              backgroundColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ChatPage(selectedDate: null),
                ),
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                color: isDark ? Colors.white : Colors.black87,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
