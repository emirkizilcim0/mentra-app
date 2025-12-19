import 'package:flutter/material.dart';
import 'package:mentra_app/pages/dairy/write/dairy_write_page.dart';
import 'package:mentra_app/providers/theme_provider.dart';
import 'package:mentra_app/services/dairy/dairy_service.dart';
import 'package:provider/provider.dart';

import 'logic_data.dart';
import 'logic_nav.dart';
import 'analysis_dialog.dart';
import 'chat_view.dart';

class ChatPage extends StatefulWidget {
  final DateTime? selectedDate;
  const ChatPage({super.key, this.selectedDate});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<Map<String, dynamic>> diaries = [];
  bool loading = true;
  String? error;
  String name = "User", sign = "", type = "";

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final user = await LogicData.loadUserData();
    setState(() {
      name = user['name'] ?? "User";
      sign = user['sign'] ?? "";
      type = user['type'] ?? "";
    });
    await _loadDiaries();
  }

  Future<void> _loadDiaries() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final items = await LogicData.loadDiaries();
      setState(() {
        diaries = items;
        loading = false;
      });
      if (mounted)
        LogicNav.checkForAutoOpen(
          context,
          widget.selectedDate,
          items,
          Provider.of<ThemeProvider>(context, listen: false).isDarkMode,
        );
    } catch (e) {
      setState(() {
        loading = false;
        error = 'Failed to load.';
      });
    }
  }

  Future<void> _getAdvice(Map<String, dynamic>? entry) async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Analyzing...')));
    try {
      final analysis = await DiaryService.analyzeDiaries(
        characterType: type,
        sign: sign,
        birthMap: 'Not specified',
        diaryCount: entry == null ? diaries.length : 1,
      );
      if (mounted)
        showAnalysisDialog(
          context,
          Provider.of<ThemeProvider>(context, listen: false).isDarkMode,
          analysis,
          name,
          type,
          sign,
          entry == null ? 'Analysis' : 'Advice: ${entry['formattedDate']}',
        );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _write() async {
    final res = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DiaryWritePage()),
    );
    if (res != null) {
      await DiaryService.saveDiaryEntry(res);
      _loadDiaries();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Saved!'),
          action: SnackBarAction(
            label: 'Get Advice',
            onPressed: () => _getAdvice(null),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Provider.of<ThemeProvider>(context).isDarkMode
          ? const Color(0xFF121212)
          : const Color(0xFFE8F4F9),
      body: ChatViewBody(
        isDark: Provider.of<ThemeProvider>(context).isDarkMode,
        isLoading: loading,
        error: error,
        entries: diaries,
        onRefresh: _loadDiaries,
        onWrite: _write,
        onDetail: (e) => LogicNav.openDiaryDetail(context, e),
        onAdvice: _getAdvice,
      ),
    );
  }
}
