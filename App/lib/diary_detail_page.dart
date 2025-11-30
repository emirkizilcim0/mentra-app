import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class DiaryDetailPage extends StatelessWidget {
  final Map<String, dynamic> diaryEntry;

  const DiaryDetailPage({super.key, required this.diaryEntry});

  @override
  Widget build(BuildContext context) {
    final title =
        (diaryEntry['title'] ?? _titleFromContent(diaryEntry['content'] ?? ''))
            .toString();
    final dateText =
        (diaryEntry['formattedDate'] ?? _formatDate(diaryEntry['date']))
            .toString();

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDFBF7),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Diary Entry',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final minHeight = constraints.maxHeight - 32; // padding compensation
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: minHeight.clamp(0, double.infinity),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 4,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          Text(
                            dateText,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            title,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            (diaryEntry['content'] ?? '').toString(),
                            style: GoogleFonts.lato(
                              fontSize: 16,
                              color: Colors.black87,
                              height: 1.8,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

String _titleFromContent(String content) {
  final text = content.trim();
  if (text.isEmpty) return 'Untitled';
  final dot = text.indexOf('.');
  final first = dot > 0 ? text.substring(0, dot) : text.split('\n').first;
  return first.length <= 60 ? first : '${first.substring(0, 60)}...';
}

String _formatDate(dynamic iso) {
  try {
    if (iso is String) {
      final d = DateTime.tryParse(iso);
      if (d != null) return DateFormat('dd MMMM yyyy, HH:mm').format(d);
    }
  } catch (_) {}
  return '';
}

// mood etiketi ve emoji kaldırıldı
