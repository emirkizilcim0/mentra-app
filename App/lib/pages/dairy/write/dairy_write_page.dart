import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mentra_app/pages/dairy/write/write_header.dart';
import 'package:mentra_app/pages/dairy/write/write_inputs.dart';
import 'package:mentra_app/pages/dairy/write/write_logic.dart';
import 'package:mentra_app/pages/dairy/write/write_styles.dart';
// Dosya yollarını kontrol et

class DiaryWritePage extends StatefulWidget {
  const DiaryWritePage({super.key});
  @override
  State<DiaryWritePage> createState() => _DiaryWritePageState();
}

class _DiaryWritePageState extends State<DiaryWritePage> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton(
              onPressed: () => WriteLogic.saveDiary(
                context,
                _formKey,
                _titleCtrl.text,
                _contentCtrl.text,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD68DA8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Save',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: WriteStyles.gradientBackground,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 100, 16, 20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: WriteStyles.cardDecoration,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const WriteHeader(),
                  TitleInput(controller: _titleCtrl),
                  const Divider(),
                  ContentInput(controller: _contentCtrl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
