import 'package:flutter/material.dart';
import 'package:mentra_app/pages/dairy/write/dairy_write_page.dart';
import 'package:mentra_app/providers/theme_provider.dart';
import 'package:mentra_app/services/dairy/dairy_service.dart';
import 'package:provider/provider.dart';
import 'package:mentra_app/pages/advice/details/advice_details_page.dart';
import 'package:intl/intl.dart';
import '../home/loading_view.dart';
import 'logic_data.dart';
import 'logic_nav.dart';
import 'chat_view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mentra_app/services/advice_notifier.dart';
import 'package:mentra_app/services/dairy/dairy_auth.dart';

class ChatPage extends StatefulWidget {
  final DateTime? selectedDate;
  final bool showAdvice;
  const ChatPage({super.key, this.selectedDate, this.showAdvice = false});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<Map<String, dynamic>> diaries = [];
  bool loading = true;
  bool _isAnalyzing = false;
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

  String _formatDate(dynamic dateStr) {
    try {
      if (dateStr == null) return "";
      DateTime date;
      if (dateStr is DateTime) {
        date = dateStr;
      } else {
        date = DateTime.parse(dateStr.toString());
      }
      return DateFormat('d MMMM, yyyy', 'en_US').format(date.toLocal());
    } catch (_) {
      return dateStr.toString();
    }
  }

  Future<void> _saveAnalysisToAPI(Map<String, dynamic> data) async {
    try {
      print('💾 Saving analysis to API:');
      print('   Data keys: ${data.keys.toList()}');
      print('   user_id: ${data['user_id']}');
      print('   diary_id: ${data['diary_id']}');
      print('   advice length: ${data['advice']?.toString().length ?? 0}');

      final userId = DiaryAuth.getUserId();

      final res = await http.post(
        Uri.parse(
          'https://mentra-app-b2ei.onrender.com/analyses?user_id=$userId',
        ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      print('📡 Save response: ${res.statusCode} - ${res.body}');

      if (res.statusCode != 200 && res.statusCode != 201) {
        print("❌ Error saving to API: ${res.statusCode} - ${res.body}");
      } else {
        print("✅ Analysis saved to API successfully!");
      }
    } catch (e) {
      print("❌ Exception during saving: $e");
    }
  }

  Future<List<Map<String, dynamic>>> _fetchAnalysesFromAPI() async {
    try {
      final userId = DiaryAuth.getUserId();
      final response = await http.get(
        Uri.parse(
          'https://mentra-app-b2ei.onrender.com/analyses?user_id=$userId',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        return data.map<Map<String, dynamic>>((item) {
          final analysis = item as Map<String, dynamic>;

          return {
            'diary_id': analysis['diary_id']?.toString(),
            'advice': analysis['advice'] ?? '',
            'analysis': analysis['analysis'] ?? '',
            'mood': analysis['mood'] ?? 'Calm',
            'has_advice': true,
            'seen': analysis['seen'] ?? false,
          };
        }).toList();
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Fetch analyses error: $e');
      return [];
    }
  }

  Future<void> _loadDiaries() async {
    setState(() {
      diaries = [];
      loading = true;
      error = null;
    });

    try {
      // 1. Load diaries from backend
      final items = await DiaryService.getDiaryEntries();

      // 2. Load analyses from PostgreSQL API
      final List<Map<String, dynamic>> analysesList =
          await _fetchAnalysesFromAPI();

      // 3. Match diaries with analyses
      for (var item in items) {
        // Format date
        if (item['date'] != null) {
          item['formattedDate'] = _formatDate(item['date']);
        }

        String diaryId = item['id']?.toString() ?? "";

        // Find matching analysis in database
        final matchingAnalysis = analysesList.firstWhere(
          (analysis) => analysis['diary_id'].toString() == diaryId,
          orElse: () => {},
        );

        if (matchingAnalysis.isNotEmpty) {
          item['advice'] = matchingAnalysis['advice'] ?? '';
          item['analysis'] = matchingAnalysis['analysis'] ?? '';
          item['mood'] = matchingAnalysis['mood'] ?? 'Calm';
          item['has_advice'] = true;
          item['seen'] = matchingAnalysis['seen'] ?? false;
        } else {
          item['has_advice'] = false;
          item['seen'] = false;
        }
      }

      setState(() {
        diaries = items;
        loading = false;
      });

      // Auto-open logic
      if (mounted && widget.selectedDate != null && widget.showAdvice) {
        String y = widget.selectedDate!.year.toString();
        String m = widget.selectedDate!.month.toString().padLeft(2, '0');
        String d = widget.selectedDate!.day.toString().padLeft(2, '0');
        String targetKey = "$y-$m-$d";
        final foundEntry = items.firstWhere(
          (e) => e['date'].toString().contains(targetKey),
          orElse: () => {},
        );
        if (foundEntry.isNotEmpty)
          _getAdvice(foundEntry);
        else
          _getAdvice(null);
      } else if (mounted) {
        LogicNav.checkForAutoOpen(
          context,
          widget.selectedDate,
          items,
          Provider.of<ThemeProvider>(context, listen: false).isDarkMode,
        );
      }
    } catch (e) {
      print("Yükleme Hatası: $e");
      setState(() {
        loading = false;
        error = 'Failed to load.';
      });
    }
  }

  Future<void> _getAdvice(Map<String, dynamic>? entry) async {
    if (_isAnalyzing) return;

    setState(() {
      _isAnalyzing = true;
    });

    print("📢 1. BAŞLANGIÇ: _getAdvice çalıştı.");

    try {
      String? diaryId;

      if (entry != null) {
        diaryId = entry['id']?.toString() ?? "";

        // PERMANENT CHECK: If diary already has advice in PostgreSQL
        if (entry['has_advice'] == true) {
          print("📢 2. DURUM: Zaten advice var, direkt açılıyor.");

          // Prepare data for viewing
          Map<String, dynamic> viewData = {
            'date': entry['date'],
            'formattedDate': _formatDate(entry['date']),
            'diary_id': diaryId,
            'advice': entry['advice'] ?? '',
            'analysis': entry['analysis'] ?? '',
            'mood': entry['mood'] ?? 'Calm',
            'character_type': type,
            'sign': sign,
            'has_advice': true,
            'seen': true,
          };

          AdviceNotifier().notifyNewAdviceCreated();

          setState(() {
            _isAnalyzing = false;
          });

          // ✅ MARK AS SEEN
          setState(() {
            entry['seen'] = true;
          });

          // Mark as seen in backend
          if (entry['analysis_id'] != null) {
            await DiaryService.markAnalysisAsSeen(
              int.parse(entry['analysis_id'].toString()),
            );
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdviceDetailPage(
                analysisItem: viewData,
                title: "Daily Advice",
              ),
            ),
          );
          return;
        }
      }

      print("📢 3. ID TESPİTİ: İşlem yapılacak ID: $diaryId");

      // AI Analizi
      print("📢 4. DURUM: AI servisine gidiliyor...");
      final Map<String, dynamic> response = await DiaryService.analyzeDiaries(
        characterType: type,
        sign: sign,
        birthMap: 'Not specified',
        diaryCount: entry == null ? 1 : 0,
        specificContent: entry != null
            ? (entry['content'] ?? entry['text'] ?? "")
            : null,
        specificIds: diaryId != null ? [diaryId] : null,
      );
      print("📢 5. DURUM: AI cevabı geldi.");

      Map<String, dynamic> finalData = {};

      // ✅ Extract from results[0]
      if (response['results'] != null &&
          response['results'] is List &&
          response['results'].isNotEmpty) {
        final first = response['results'][0];

        finalData['advice'] = first['advice'] ?? '';
        finalData['analysis'] = first['advice'] ?? '';
        finalData['mood'] = first['mood'] ?? 'Calm';
      } else {
        finalData['advice'] = response['advice'] ?? '';
        finalData['analysis'] = response['advice'] ?? '';
        finalData['mood'] = response['mood'] ?? 'Calm';
      }

      // Prepare data for navigation
      finalData['date'] = entry?['date'];
      finalData['formattedDate'] = entry != null
          ? _formatDate(entry['date'])
          : '';
      finalData['diary_id'] = diaryId;
      finalData['has_advice'] = true;
      finalData['character_type'] = type;
      finalData['sign'] = sign;
      finalData['mood'] ??= 'Calm';

      // Save analysis to database
      if (diaryId != null &&
          diaryId.isNotEmpty &&
          finalData['advice'].toString().isNotEmpty) {
        try {
          await DiaryService.saveAnalysis(
            diaryId: int.parse(diaryId),
            advice: finalData['advice'].toString(),
            analysis: finalData['analysis'].toString(),
            characterType: type,
            sign: sign,
            mood: finalData['mood'].toString(),
            moodSource: 'ai_detected',
            hasAdvice: true,
            seen: false,
          );
          AdviceNotifier().notifyNewAdviceCreated();
          print('✅ Analysis saved to database');
        } catch (e) {
          print('⚠️ Failed to save analysis: $e');
        }
      }

      if (mounted && entry != null) {
        setState(() {
          entry['advice'] = finalData['advice'];
          entry['analysis'] = finalData['analysis'];
          entry['mood'] = finalData['mood'];
          entry['has_advice'] = true;
          entry['seen'] = false;
        });
      }

      // Navigate to advice page
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdviceDetailPage(
              analysisItem: finalData,
              title: entry != null ? "Daily Advice" : "Analysis Result",
            ),
          ),
        );

        // Refresh from database after delay
        Future.delayed(Duration(seconds: 1), () {
          if (mounted) {
            _loadDiaries();
          }
        });
      }
    } catch (e) {
      print("❌❌❌ GENEL HATA: $e ❌❌❌");
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _write() async {
    final res = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DiaryWritePage()),
    );

    if (res != null) {
      await DiaryService.saveDiaryEntry(res);
      await _loadDiaries();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Diary saved successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: isDark
              ? const Color(0xFF121212)
              : const Color(0xFFE8F4F9),
          body: ChatViewBody(
            isDark: isDark,
            isLoading: loading,
            error: error,
            entries: diaries,
            onRefresh: _loadDiaries,
            onWrite: _write,
            onDetail: (e) => LogicNav.openDiaryDetail(context, e),
            onAdvice: _getAdvice,
          ),
        ),
        if (_isAnalyzing) Positioned.fill(child: LoadingView(isDark: isDark)),
      ],
    );
  }
}
