import 'package:flutter/material.dart';
import 'package:mentra_app/providers/theme_provider.dart';
import 'package:mentra_app/services/dairy/dairy_service.dart';
import 'package:provider/provider.dart';

import 'advice_view_body.dart';

class AdvicePage extends StatefulWidget {
  const AdvicePage({super.key});
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
    _loadAnalyses();
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
