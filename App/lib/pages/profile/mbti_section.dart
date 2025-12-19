import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mentra_app/mbti/result_screen.dart'; // Dosya yolunu kontrol et!

class MbtiSection extends StatelessWidget {
  final String title, desc, type;

  const MbtiSection({
    super.key,
    required this.title,
    required this.desc,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.pink[900]!.withOpacity(0.3)
            : const Color(0xFFF9DDE2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(15), // Tıklama efekti sınırı
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ResultScreen(
                    scores: {},
                    onRetakeTest: () =>
                        Navigator.pushNamed(context, "/testPage"),
                  ),
                ),
              );
            },
            child: Text(
              type.isNotEmpty ? "$type - $title" : title,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: colorScheme.onBackground,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, "/testPage"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF48FB1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text("Retake"),
          ),
        ],
      ),
    );
  }
}
