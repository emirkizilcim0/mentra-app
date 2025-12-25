import 'dart:ui'; // ImageFilter için gerekli
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mentra_app/providers/theme_provider.dart';
import 'profile_actions.dart';

class ProfileTopBar extends StatelessWidget {
  final ThemeProvider themeProvider;
  final VoidCallback onSave;

  const ProfileTopBar({
    super.key,
    required this.themeProvider,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = themeProvider.isDarkMode;

    return SafeArea(
      bottom: false,
      child: Padding(
        // Barın ekran kenarlarından uzaklığı
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                // Bottom bar ile aynı opaklık ve renk mantığı
                color: (isDark ? Colors.black : Colors.white).withOpacity(0.3),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: (isDark ? Colors.white : Colors.white).withOpacity(
                    isDark ? 0.2 : 0.5,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo Kısmı
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Text(
                      "Mentra",
                      style: GoogleFonts.pacifico(
                        fontSize: 26,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  // Aksiyon Butonları (Kaydet, Tema vs.)
                  ProfileActions(themeProvider: themeProvider, onSave: onSave),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
