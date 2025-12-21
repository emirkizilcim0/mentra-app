// lib/info_page.dart
import 'package:flutter/material.dart';
import 'package:mentra_app/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'info_page_mixin.dart';
import 'info_theme_colors.dart';
import 'top_bar_section.dart';
import 'info_form_section.dart';
import 'okay_button.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});
  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> with InfoPageMixin {
  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Scaffold(
      backgroundColor: InfoColors.bg(isDark),
      body: Stack(
        children: [
          Column(
            children: [
              TopBarSection(isDark: isDark),
              const SizedBox(height: 80),
              InfoFormSection(isDark: isDark, ctrls: controllers),
              const SizedBox(height: 50),
              OkayButton(isDark: isDark),
              const Spacer(),
            ],
          ),
        ],
      ),
    );
  }
}
