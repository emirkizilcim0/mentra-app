import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'profile_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final month = DateFormat.MMMM().format(now);
    final year = now.year;

    return Scaffold(
      backgroundColor: const Color(0xFFE8F4F9),
      body: SafeArea(
        child: Column(
          children: [
            // 🩶 Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Mentra",
                    style: GoogleFonts.pacifico(
                      fontSize: 28,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.black87,
                      size: 26,
                    ),
                  ),
                ],
              ),
            ),

            // 🗓 Calendar Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black12, width: 1.5),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "$month",
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        "$year",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Days of week
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
                        .map(
                          (d) => Text(
                            d,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 10),

                  // Calendar grid (just for show)
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(31, (index) {
                      final day = index + 1;
                      final isToday = day == now.day;
                      return Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: isToday
                              ? const Color(0xFFB3E5FC)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.black26),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "$day",
                          style: GoogleFonts.poppins(
                            fontWeight: isToday
                                ? FontWeight.bold
                                : FontWeight.w400,
                            color: Colors.black87,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            // 🔮 Horoscope Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9DDE2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black26, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_fix_high, color: Colors.black87),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Taurus Daily Horoscope (${DateFormat.MMMM().format(now)} ${now.day}, $year):", // dynamic date.
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Stay calm and patient today. Even if small setbacks occur, your steady approach will help you end the day feeling accomplished and grounded. 🐂✨",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // ⚙️ Bottom Navigation Bar
            Container(
              height: 65,
              decoration: const BoxDecoration(
                color: Color(0xFFD0E8EF),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.home, size: 28, color: Colors.black),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.person_outline,
                      size: 28,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfilePage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
