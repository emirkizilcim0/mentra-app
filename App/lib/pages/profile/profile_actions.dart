import 'package:flutter/material.dart';
import 'package:mentra_app/providers/theme_provider.dart';
import 'blur_icon_button.dart'; // Yeni dosyayı import et

class ProfileActions extends StatelessWidget {
  final ThemeProvider themeProvider;
  final VoidCallback onSave;

  const ProfileActions({
    super.key,
    required this.themeProvider,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        BlurIconButton(
          icon: themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
          onPressed: themeProvider.toggleTheme,
        ),
        const SizedBox(width: 8),
        BlurIconButton(icon: Icons.save, onPressed: onSave),
      ],
    );
  }
}
