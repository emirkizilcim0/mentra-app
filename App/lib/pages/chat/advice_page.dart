import 'package:flutter/material.dart';
import 'package:mentra_app/providers/theme_provider.dart';
import 'package:mentra_app/services/dairy/dairy_service.dart';
import 'package:provider/provider.dart';

import 'advice_view_body.dart';

class AdvicePage extends StatefulWidget {
  // 1. BU İKİ DEĞİŞKENİ EKLE: Dışarıdan veri alabilmesi için
  final String? generatedAdvice;
  final String? date;

  const AdvicePage({super.key, this.generatedAdvice, this.date});

  @override
  State<AdvicePage> createState() => _AdvicePageState();
}

class _AdvicePageState extends State<AdvicePage> {
  List<Map<String, dynamic>> analyses = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    // 2. KONTROL MANTIĞI: Veri geldi mi yoksa geçmişi mi çekelim?
    if (widget.generatedAdvice != null) {
      // Eğer ChatPage'den veri geldiyse, direkt onu ekrana bas
      setState(() {
        analyses = [
          {
            'analysis': widget
                .generatedAdvice, // AdviceViewBody'nin beklediği key (muhtemelen 'analysis' veya 'content')
            'created_at': widget.date ?? DateTime.now().toString(),
          },
        ];
        isLoading = false;
      });
    } else {
      // Veri gelmediyse (Menüden açıldıysa) geçmişi yükle
      _loadAnalyses();
    }
  }

  Future<void> _loadAnalyses() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
      final items = await DiaryService.getAnalysisHistory(limit: 50);
      setState(() {
        analyses = items;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Advices aren't available at the moment.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFE8F4F9),
      appBar: AppBar(
        title: const Text('Advice'),
        actions: [
          // Eğer tek bir advice gösteriyorsak refresh butonu geçmişe dönmeyi sağlayabilir
          IconButton(onPressed: _loadAnalyses, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: AdviceViewBody(
        isLoading: isLoading,
        errorMessage: errorMessage,
        analyses: analyses,
        isDark: isDark,
      ),
    );
  }
}
