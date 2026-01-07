import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mentra_app/mbti/result_screen.dart';
import 'package:mentra_app/mbti/services/mbti_calculator.dart';
import 'package:provider/provider.dart';
import 'package:mentra_app/providers/theme_provider.dart';
import 'package:mentra_app/mbti/data/questions_data.dart';
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

  @override
  void initState() {
    super.initState();
    _calculator.reset(); // Sayfa her açıldığında skorları temizle
  }

  void _next() async {
    if (_answer == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select an option.")));
      return;
    }

    // Puanı ekle
    String typeToScore = mbtiQuestions[_idx].scoreType;
    _calculator.addScore(typeToScore, _answer!);

    if (_idx < mbtiQuestions.length - 1) {
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
      // 1. Loading diyaloğunu aç
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => const Center(child: CircularProgressIndicator()),
      );

      // 2. Sonuçları hesapla
      String finalResult = _calculator.calculateResult();
      var details = _calculator.getPersonalityResult();

      // 3. Firebase kaydı
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

      // 4. Loading diyaloğunu kapat (Güvenli yöntem)
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      // 5. Sonuç ekranına git ve geçmişi temizle
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(mbtiResult: finalResult),
          ),
          (route) => false, // Geri tuşuyla teste dönülmesini engeller
        );
      }
    } catch (e) {
      // Hata durumunda diyaloğu kapat ve kullanıcıyı bilgilendir
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        print("🔥 Kayıt Hatası: $e");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("An error occurred: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    if (mbtiQuestions.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final String qText = mbtiQuestions[_idx].question;

    return Scaffold(
      body: TestViewBody(
        isDark: isDark,
        question: qText,
        index: _idx,
        total: mbtiQuestions.length,
        selectedAnswer: _answer,
        onAnswer: (val) => setState(() => _answer = val),
        onNext: _next,
      ),
    );
  }
}
