import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'chat_styles.dart';
import 'chat_utils.dart';
import 'package:intl/intl.dart';

class DiaryCard extends StatelessWidget {
  final Map<String, dynamic> entry;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onAdvice;

  const DiaryCard({
    super.key,
    required this.entry,
    required this.isDark,
    required this.onTap,
    required this.onAdvice,
  });

  @override
  Widget build(BuildContext context) {
    // Advice var mı kontrolü
    bool hasAdvice =
        (entry['advice'] != null && entry['advice'].toString().isNotEmpty) ||
        (entry['analysis'] != null && entry['analysis'].toString().isNotEmpty);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: getCardColor(isDark),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [getShadow(isDark)],
      ),
      child: InkWell(
        onTap: onTap, // Kartın kendisine tıklayınca detay açılır
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry['date'] != null
                        ? DateFormat('d MMMM, yyyy').format(
                            // Gelen veri String mi DateTime mı kontrol edip ona göre çeviriyoruz
                            entry['date'] is DateTime
                                ? entry['date']
                                : DateTime.parse(entry['date'].toString()),
                          )
                        : 'No date',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: getTextColor(isDark),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry['title'] ?? titleFromContent(entry['content'] ?? ''),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // --- BURASI DEĞİŞTİ ---
            // Eğer advice VARSA butonu göster, YOKSA gösterme.
            // --- ADVICE BUTONU MANTIĞI ---

            // DURUM 1: Eğer tavsiye daha önce alınmışsa (Veritabanında varsa)
            if (hasAdvice)
              InkWell(
                onTap:
                    onAdvice, // Direkt sayfayı açar (ChatPage'deki mantık sayesinde)
                child: Container(
                  margin: const EdgeInsets.only(left: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.deepPurple.shade300
                        : Colors.deepPurple.shade100,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.visibility, // "Görüntüle" ikonu
                        size: 16,
                        color: Colors.deepPurple.shade900,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'See Advice',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.deepPurple.shade900,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            // DURUM 2: Eğer tavsiye HENÜZ ALINMAMIŞSA
            else
              InkWell(
                onTap: onAdvice, // Analizi başlatır ve kaydeder
                child: Container(
                  margin: const EdgeInsets.only(left: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    // Dikkat çekmesi için Amber/Turuncu tonları
                    color: isDark
                        ? Colors.amber.shade700
                        : Colors.amber.shade200,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.auto_awesome, // "Sihir/Yarat" ikonu
                        size: 16,
                        color: isDark ? Colors.white : Colors.brown.shade800,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Get Advice',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white : Colors.brown.shade800,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // Advice yoksa hiçbir şey koymuyoruz (SizedBox yok)
          ],
        ),
      ),
    );
  }
}
