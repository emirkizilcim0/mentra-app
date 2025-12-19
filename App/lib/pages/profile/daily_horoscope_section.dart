import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mentra_app/services/local_horoscope_service.dart';

class DailyHoroscopeSection extends StatelessWidget {
  const DailyHoroscopeSection({super.key});

  String _getEnglishSign(String? dbSign) {
    if (dbSign == null) return 'Aries';

    final cleanSign = dbSign.trim().toLowerCase();

    final Map<String, String> map = {
      'koç': 'Aries',
      'koc': 'Aries',
      'aries': 'Aries',
      'boğa': 'Taurus',
      'boga': 'Taurus',
      'taurus': 'Taurus',
      'ikizler': 'Gemini',
      'gemini': 'Gemini',
      'yengeç': 'Cancer',
      'yengec': 'Cancer',
      'cancer': 'Cancer',
      'aslan': 'Leo',
      'leo': 'Leo',
      'başak': 'Virgo',
      'basak': 'Virgo',
      'virgo': 'Virgo',
      'terazi': 'Libra',
      'libra': 'Libra',
      'akrep': 'Scorpio',
      'scorpio': 'Scorpio',
      'yay': 'Sagittarius',
      'sagittarius': 'Sagittarius',
      'oğlak': 'Capricorn',
      'oglak': 'Capricorn',
      'capricorn': 'Capricorn',
      'kova': 'Aquarius',
      'aquarius': 'Aquarius',
      'balık': 'Pisces',
      'balik': 'Pisces',
      'pisces': 'Pisces',
    };

    return map[cleanSign] ?? 'Aries';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return const SizedBox.shrink();

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.hasError) {
          return const SizedBox.shrink();
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>?;

        // --- DÜZELTME BURADA YAPILDI ---
        // Artık öncelikle 'zodiac' alanına bakıyor (Senin veritabanın böyle kaydediyor)
        // Eğer orada bulamazsa 'sign' alanına bakıyor.
        final String? userSignRaw =
            userData?['zodiac'] ??
            userData?['sign'] ??
            userData?['zodiac_sign'];

        if (userSignRaw == null || userSignRaw.isEmpty)
          return const SizedBox.shrink();

        final String englishSign = _getEnglishSign(userSignRaw);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Daily Horoscope",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: colorScheme.onBackground,
                  ),
                ),
                Text(
                  englishSign,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.deepPurpleAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FutureBuilder<String>(
                future: LocalHoroscopeService.getDailyMessage(englishSign),
                builder: (context, messageSnapshot) {
                  if (messageSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  }

                  if (messageSnapshot.hasError) {
                    return Text(
                      "Could not load horoscope.",
                      style: TextStyle(color: Colors.redAccent, fontSize: 12),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 18,
                            color: Colors.deepPurpleAccent,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Today's Insight",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        messageSnapshot.data ?? "No insight available.",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          height: 1.5,
                          color: colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }
}
