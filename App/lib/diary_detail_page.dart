import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';

class DiaryDetailPage extends StatelessWidget {
  final Map<String, dynamic> diaryEntry;

  const DiaryDetailPage({super.key, required this.diaryEntry});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode
          ? const Color(0xFF121212) // Dark mode background
          : Colors.white, // Light mode background
      appBar: AppBar(
        backgroundColor: themeProvider.isDarkMode
            ? const Color(0xFF1E1E1E) // Dark mode appbar
            : Colors.white, // Light mode appbar
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: themeProvider.isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Diary Entry',
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white : Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              diaryEntry['title'] ?? 'Untitled',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: themeProvider.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              diaryEntry['formattedDate'] ?? 'Unknown date',
              style: TextStyle(
                color: themeProvider.isDarkMode
                    ? Colors.grey[400] // Dark mode date
                    : Colors.grey[600], // Light mode date
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode
                    ? const Color(0xFF1E1E1E) // Dark mode content background
                    : Colors.grey[50], // Light mode content background
                borderRadius: BorderRadius.circular(12),
                border: themeProvider.isDarkMode
                    ? Border.all(color: Colors.grey.shade800)
                    : null,
              ),
              child: Text(
                diaryEntry['content'] ?? '',
                style: TextStyle(
                  fontSize: 16,
                  color: themeProvider.isDarkMode
                      ? Colors
                            .white // Dark mode text
                      : Colors.black87, // Light mode text
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
