import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';

class AdviceDetailPage extends StatelessWidget {
  final Map<String, dynamic> analysisItem;
  final String title;

  const AdviceDetailPage({super.key, required this.analysisItem, required this.title});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final textColor = themeProvider.isDarkMode ? Colors.white : Colors.black87;
    final bgColor = themeProvider.isDarkMode ? const Color(0xFF121212) : const Color(0xFFF7F9FC);
    final cardColor = themeProvider.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;

    final dateText = analysisItem['formattedDate'] ?? analysisItem['date'] ?? '';
    final adviceText = analysisItem['advice'] ?? '';

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Advice'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: themeProvider.isDarkMode ? Colors.black54 : Colors.black12,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      dateText,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                adviceText,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
