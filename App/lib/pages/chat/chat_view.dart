import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'write_button.dart';
import 'diary_card.dart';
import 'bottom_nav.dart';

class ChatViewBody extends StatelessWidget {
  final bool isDark;
  final bool isLoading;
  final String? error;
  final List<Map<String, dynamic>> entries;
  final VoidCallback onRefresh;
  final VoidCallback onWrite;
  final Function(Map<String, dynamic>) onDetail;
  final Function(Map<String, dynamic>) onAdvice;

  const ChatViewBody({
    super.key,
    required this.isDark,
    required this.isLoading,
    this.error,
    required this.entries,
    required this.onRefresh,
    required this.onWrite,
    required this.onDetail,
    required this.onAdvice,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Text(
                      "Mentra",
                      style: GoogleFonts.pacifico(
                        fontSize: 28,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            WriteDiaryButton(isDark: isDark, onTap: onWrite),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Your previous diaries",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.refresh,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    onPressed: onRefresh,
                  ),
                ],
              ),
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Text(
                  error!,
                  style: TextStyle(color: Colors.red.shade300),
                ),
              ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(25, 10, 25, 100),
                      itemCount: entries.length,
                      itemBuilder: (ctx, i) => DiaryCard(
                        entry: entries[i],
                        isDark: isDark,
                        onTap: () => onDetail(entries[i]),
                        onAdvice: () => onAdvice(entries[i]),
                      ),
                    ),
            ),
          ],
        ),
        ChatBottomNav(isDark: isDark),
      ],
    );
  }
}
