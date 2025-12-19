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
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                "Mentra",
                style: GoogleFonts.pacifico(
                  fontSize: 28,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
            ),
            ProfileActions(themeProvider: themeProvider, onSave: onSave),
          ],
        ),
      ),
    );
  }
}
