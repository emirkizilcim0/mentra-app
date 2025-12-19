import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void showDiarySelectionPopup(
  BuildContext context,
  List<Map<String, dynamic>> entries,
  bool isDark,
  Function(Map<String, dynamic>) onSelect,
) {
  final date = entries.first['formattedDate'] ?? 'Selected Day';
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      title: Text(
        'Dairy Choice: $date',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: entries.asMap().entries.map((item) {
            final entry = item.value;
            final content = entry['content'].toString();
            final preview = content.isNotEmpty
                ? '${content.substring(0, content.length > 50 ? 50 : content.length)}...'
                : 'İçerik yok';
            return Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.note_alt_outlined,
                    color: isDark
                        ? Colors.blueGrey.shade300
                        : Colors.blueGrey.shade700,
                  ),
                  title: Text(
                    entry['title'] ?? 'Giriş #${item.key + 1}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    preview,
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    onSelect(entry);
                  },
                ),
                if (item.key < entries.length - 1)
                  Divider(color: isDark ? Colors.grey[700] : Colors.grey[300]),
              ],
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          child: Text(
            'Close',
            style: GoogleFonts.poppins(color: Colors.redAccent),
          ),
          onPressed: () => Navigator.pop(ctx),
        ),
      ],
    ),
  );
}
