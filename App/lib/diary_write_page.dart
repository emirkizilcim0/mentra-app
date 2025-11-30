import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class DiaryWritePage extends StatefulWidget {
  const DiaryWritePage({super.key});

  @override
  State<DiaryWritePage> createState() => _DiaryWritePageState();
}

class _DiaryWritePageState extends State<DiaryWritePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveDiary() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final diaryEntry = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': _titleController.text,
        'content': _contentController.text,
        'date': now.toIso8601String(),
        'formattedDate': DateFormat('dd MMMM yyyy, HH:mm').format(now),
      };

      Navigator.pop(context, diaryEntry);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDFBF7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Write Diary',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton.icon(
              onPressed: _saveDiary,
              icon: const Icon(Icons.check, size: 18, color: Colors.white),
              label: Text(
                'Save',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Card(
              elevation: 4,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text(
                        DateFormat(
                          'dd MMMM yyyy, HH:mm',
                        ).format(DateTime.now()),
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          hintText: 'Title',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Write a title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _contentController,
                        decoration: const InputDecoration(
                          hintText: 'How was your day?',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          color: Colors.black87,
                          height: 1.7,
                        ),
                        maxLines: null,
                        minLines: 10,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Write something';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// mood özellikleri kaldırıldı
