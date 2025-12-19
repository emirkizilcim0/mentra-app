import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // 1. Provider eklendi
import 'package:mentra_app/providers/theme_provider.dart'; // 2. ThemeProvider eklendi

// Mevcut widget importları
import 'package:mentra_app/pages/dairy/write/write_header.dart';
import 'package:mentra_app/pages/dairy/write/write_inputs.dart';
import 'package:mentra_app/pages/dairy/write/write_logic.dart';
import 'package:mentra_app/pages/dairy/write/write_styles.dart';

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
    // 3. Tema durumunu dinliyoruz
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // 4. Dinamik Renk ve Tasarımlar
    final textColor = isDark ? Colors.white : Colors.black87;

    // Arka Plan: Dark mode için koyu gradient, Light mode için WriteStyles
    final backgroundDecoration = isDark
        ? const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1A1A1A), // Koyu Gri/Siyah
                Color(0xFF2C2C2C),
              ],
            ),
          )
        : WriteStyles.gradientBackground;

    // Kart Tasarımı: Dark mode için koyu kart, Light mode için WriteStyles
    final cardDecoration = isDark
        ? BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 3,
              ),
            ],
          )
        : WriteStyles.cardDecoration;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor), // Dinamik İkon Rengi
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Write Diary',
          style: GoogleFonts.poppins(
            color: textColor, // Dinamik Başlık Rengi
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
        decoration: backgroundDecoration, // Dinamik Arka Plan
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 100, 16, 20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: cardDecoration, // Dinamik Kart
            child: Form(
              key: _formKey,
              // Not: WriteHeader, TitleInput ve ContentInput widget'larının
              // içindeki metin renklerinin de (WriteStyles üzerinden veya parametre ile)
              // dinamik olması gerekir. Eğer WriteStyles.titleStyle içinde sabit
              // siyah renk varsa, dark mode'da görünmeyebilir.
              // Bu dosya özelinde kapsayıcı temayı ayarladık.
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const WriteHeader(),
                  TitleInput(controller: _titleCtrl),
                  Divider(color: isDark ? Colors.white24 : Colors.grey[300]),
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
