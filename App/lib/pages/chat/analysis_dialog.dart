import 'package:flutter/material.dart';

void showAnalysisDialog(
  BuildContext context,
  bool isDark,
  Map<String, dynamic> analysis,
  String userName,
  String type,
  String sign,
  String title,
) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      title: Text(
        title,
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (userName != "User")
              Text(
                'For: $userName',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            if (type.isNotEmpty)
              Text(
                'Personality: $type',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            if (sign.isNotEmpty)
              Text(
                'Zodiac: $sign',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            const SizedBox(height: 16),
            Text(
              analysis['advice'] ?? 'No advice available.',
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text(
            'Close',
            style: TextStyle(color: Colors.blueAccent),
          ),
        ),
      ],
    ),
  );
}
