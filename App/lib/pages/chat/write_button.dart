import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WriteDiaryButton extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;

  const WriteDiaryButton({
    super.key,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: isDark ? Colors.deepPurple.shade600 : Colors.black87,
        borderRadius: BorderRadius.circular(40),
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Write diary",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.edit, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
