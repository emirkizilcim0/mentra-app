import 'package:flutter/material.dart';
import 'package:mentra_app/mbti/data/questions_data.dart';
import 'package:provider/provider.dart';
import 'package:mentra_app/providers/theme_provider.dart';

import 'test_view_body.dart';

class MbtiTestPage extends StatefulWidget {
  const MbtiTestPage({super.key});
  @override
  State<MbtiTestPage> createState() => _MbtiTestPageState();
}

class _MbtiTestPageState extends State<MbtiTestPage> {
  int _idx = 0;
  final int _total = 70; // mbtiQuestions.length olarak da alınabilir
  int? _answer;

  // Not: Eğer questions_data.dart yoksa geçici olarak buraya liste ekleyebilirsin.
  // final List<Map<String, dynamic>> mbtiQuestions = [{'question': 'Sample Q?'}];

  void _next() {
    if (_idx < _total - 1) {
      setState(() {
        _idx++;
        _answer = null;
      });
    } else {
      Navigator.of(context).pop(); // Veya sonuç sayfasına git
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    // Hata almamak için liste kontrolü
    final qText = (mbtiQuestions.isNotEmpty && _idx < mbtiQuestions.length)
        ? mbtiQuestions[_idx].question
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
