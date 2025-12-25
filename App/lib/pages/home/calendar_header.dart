import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CalendarHeader extends StatelessWidget {
  final String month;
  final int year;
  final bool isDark;
  final VoidCallback? onYearTap;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final bool showNextButton; // Gelecek ay kontrolü

  const CalendarHeader({
    super.key,
    required this.month,
    required this.year,
    required this.isDark,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.showNextButton,
    this.onYearTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : Colors.black;
    final secondaryColor = isDark ? Colors.white70 : Colors.black87;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Sol Ok ve Ay İsmi
        Row(
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Icon(
                Icons.chevron_left_rounded,
                color: textColor,
                size: 28,
              ),
              onPressed: onPrevMonth,
            ),
            const SizedBox(width: 8),
            Text(
              month,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),

        // Yıl ve Sağ Ok
        Row(
          children: [
            GestureDetector(
              onTap: onYearTap,
              child: Text(
                "$year",
                style: GoogleFonts.poppins(fontSize: 16, color: secondaryColor),
              ),
            ),
            const SizedBox(width: 8),
            // Eğer gelecek ay mümkünse butonu göster, değilse yer tutucu boşluk koy
            showNextButton
                ? IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      Icons.chevron_right_rounded,
                      color: textColor,
                      size: 28,
                    ),
                    onPressed: onNextMonth,
                  )
                : const SizedBox(width: 28), // İkonun genişliği kadar boşluk
          ],
        ),
      ],
    );
  }
}
