import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mentra_app/pages/chat/advice_page.dart';
import 'package:mentra_app/pages/chat/chat_page.dart';
// Yolu projene göre düzenle

class DayDetailsDialog extends StatelessWidget {
  final DateTime date;
  final bool hasEntry;
  final VoidCallback? onAdviceTap;

  const DayDetailsDialog({
    super.key,
    required this.date,
    required this.hasEntry,
    this.onAdviceTap, // Constructor'a ekledik
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        DateFormat('d MMMM').format(date).toUpperCase(),
        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            ListTile(
              leading: const Icon(
                Icons.book_outlined,
                color: Color.fromARGB(255, 41, 68, 81),
              ),
              title: Text(
                'Daily Diary',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: hasEntry
                  ? () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatPage(selectedDate: date),
                        ),
                      );
                    }
                  : null,
            ),
            const Divider(),

            // ... DayDetailsDialog içindeki Advice ListTile kısmı ...
            ListTile(
              leading: const Icon(
                Icons.lightbulb_outline,
                color: Color(0xFFB3E5FC),
              ),
              title: Text(
                'Advice',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),

              // --- DEĞİŞİKLİK BURADA ---
              // hasEntry true ise (yani günlük varsa) butonu aktif ediyoruz.
              onTap: hasEntry
                  ? () {
                      Navigator.pop(context); // Diyaloğu kapat
                      if (onAdviceTap != null)
                        onAdviceTap!(); // Fonksiyonu çalıştır
                    }
                  : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text('Close', style: GoogleFonts.poppins(color: Colors.red)),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
