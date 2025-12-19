import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mentra_app/mbti/result_screen.dart';
import 'package:mentra_app/mbti/services/mbti_calculator.dart';
import 'package:provider/provider.dart';
import 'package:mentra_app/providers/theme_provider.dart';

// --- İMPORTLARI KONTROL ET ---
import 'package:mentra_app/mbti/data/questions_data.dart'; // Senin attığın veri dosyası

import 'test_view_body.dart';

class MbtiTestPage extends StatefulWidget {
  const MbtiTestPage({super.key});
  @override
  State<MbtiTestPage> createState() => _MbtiTestPageState();
}

class _MbtiTestPageState extends State<MbtiTestPage> {
  int _idx = 0;
  final int _total = 70;
  int? _answer;

  // Hesaplayıcıyı başlat
  final MbtiCalculator _calculator = MbtiCalculator();

  void _next() async {
    // 1. Cevap kontrolü
    if (_answer == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select an option.")));
      return;
    }

    // 2. PUANLAMA (KRİTİK KISIM)
    // Senin veri dosyandaki "score_type" alanını (E, S, T, J) alıyoruz.
    // Question modelinde bu alanın adı 'scoreType' olarak tanımlanmış olmalı.
    // Eğer hata alırsan modelindeki isme bak (örn: .score_type veya .dimension)
    String typeToScore = mbtiQuestions[_idx].scoreType;

    _calculator.addScore(typeToScore, _answer!);

    // 3. İLERLEME VEYA BİTİRME
    if (_idx < _total - 1) {
      setState(() {
        _idx++;
        _answer = null;
      });
    } else {
      await _finishTestAndSave();
    }
  }

  Future<void> _finishTestAndSave() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => const Center(child: CircularProgressIndicator()),
      );

      // Sonucu hesapla
      String finalResult = _calculator.calculateResult();
      var details = _calculator.getPersonalityResult();

      // Firebase'e kaydet
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'mbtiResult': finalResult,
          'mbtiTitle': details.title,
          'mbtiDesc': details.description,
          'testCompleted': true,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      if (mounted) Navigator.pop(context); // Yükleniyor'u kapat

      // Sonuç ekranına git
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(mbtiResult: finalResult),
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      print("Kayıt Hatası: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    // Veri listesi boş mu kontrolü
    final String qText =
        (mbtiQuestions.isNotEmpty && _idx < mbtiQuestions.length)
        ? mbtiQuestions[_idx]
              .question // Map değil, Nesne erişimi (.question)
        : "Loading...";

    return Scaffold(
      body: TestViewBody(
        isDark: isDark,
        question: qText,
        index: _idx,
        total: _total,
        selectedAnswer: _answer,
        onAnswer: (val) => setState(() => _answer = val),
        onNext: _next,
      ),
    );
  }
}
