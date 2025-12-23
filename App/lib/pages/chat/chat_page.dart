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

  // --- PostgreSQL API'DEN ANALİZLERİ ÇEK ---
  Future<List<Map<String, dynamic>>> _fetchAnalysesFromAPI() async {
    try {
      final response = await http.get(
        Uri.parse('https://mentra-app-b2ei.onrender.com/analyses'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Process each analysis to ensure has_advice is true
        return data.map<Map<String, dynamic>>((item) {
          final analysis = item as Map<String, dynamic>;

          // Ensure has_advice is always true from PostgreSQL
          analysis['has_advice'] = true;

          // Also ensure the diary_id field exists (some APIs might use different names)
          if (analysis['diary_id'] == null && analysis['id'] != null) {
            analysis['diary_id'] = analysis['id'].toString();
          }

          return analysis;
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

  // --- PostgreSQL API'YE ANALİZ KAYDET ---
  Future<bool> _saveAnalysisToAPI(Map<String, dynamic> analysisData) async {
    try {
      print('📤 Saving analysis for diary: ${analysisData['diary_id']}');

      // Ensure has_advice is always true
      analysisData['has_advice'] = true;

      final response = await http.post(
        Uri.parse('https://mentra-app-b2ei.onrender.com/analyses'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(analysisData),
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 404) {
        print('✅ Analysis saved to PostgreSQL with has_advice=true');
        return true;
      } else {
        print('❌ API Save Error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ API Save Exception: $e');
      return false;
    }
  }

  Future<void> _loadDiaries() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      // 1. Load diaries from phone
      final items = await LogicData.loadDiaries();

      // 2. Load analyses from PostgreSQL API
      final List<Map<String, dynamic>> analysesList =
          await _fetchAnalysesFromAPI();

      // 3. Match diaries with analyses
      for (var item in items) {
        // Format date
        if (item['date'] != null) {
          item['formattedDate'] = _formatDate(item['date']);
        }

        String localId =
            item['id']?.toString() ?? item['_id']?.toString() ?? "";

        // Find matching analysis in database
        final matchingAnalysis = analysesList.firstWhere(
          (analysis) => analysis['diary_id'].toString() == localId,
          orElse: () => {},
        );

        if (matchingAnalysis.isNotEmpty) {
          // Diary HAS advice in PostgreSQL - PERMANENT
          item['advice'] = matchingAnalysis['advice'] ?? '';
          item['analysis'] = matchingAnalysis['analysis'] ?? '';
          item['mood'] = matchingAnalysis['mood'] ?? 'Calm';
          item['has_advice'] = true; // CRITICAL: From PostgreSQL
        } else {
          // Diary has NO advice in database
          item['has_advice'] = false;
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

  // --- ADVICE FONKSİYONU ---
  Future<void> _getAdvice(Map<String, dynamic>? entry) async {
    if (_isAnalyzing) return;

    setState(() {
      _isAnalyzing = true;
    });

    print("📢 1. BAŞLANGIÇ: _getAdvice çalıştı.");

    try {
      String? currentId;
      if (entry != null) {
        currentId = entry['id']?.toString() ?? entry['_id']?.toString();

        // PERMANENT CHECK: If diary already has advice in PostgreSQL
        if (entry['has_advice'] == true) {
          print("📢 2. DURUM: Zaten advice var, direkt açılıyor.");

          // Prepare data for viewing
          Map<String, dynamic> viewData = {
            'date': entry['date'],
            'formattedDate': _formatDate(entry['date']),
            'diary_id': currentId,
            'advice': entry['advice'] ?? '',
            'analysis': entry['analysis'] ?? '',
            'mood': entry['mood'] ?? 'Calm',
            'character_type': type,
            'sign': sign,
            'has_advice': true,
          };

          setState(() {
            _isAnalyzing = false;
          });

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

      print("📢 3. ID TESPİTİ: İşlem yapılacak ID: $currentId");

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
        specificIds: currentId != null ? [currentId] : null,
      );
      print("📢 5. DURUM: AI cevabı geldi.");

      Map<String, dynamic> finalData = Map.of(response);

      // --- KAYIT KISMI (POSTGRESQL API'YE KAYDET) ---
      if (entry != null && currentId != null) {
        print("📢 6. DURUM: PostgreSQL API'ye yazma işlemi başlıyor...");

        // Save to PostgreSQL API
        final bool saveSuccess = await _saveAnalysisToAPI({
          'diary_id': currentId,
          'advice': finalData['advice'] ?? '',
          'analysis': finalData['analysis'] ?? '',
          'mood': finalData['mood'] ?? 'Calm',
          'character_type': type,
          'sign': sign,
          'has_advice': true, // PERMANENT flag
          'created_at': DateTime.now().toIso8601String(),
        });

        if (saveSuccess) {
          print("✅✅✅ 7. BAŞARI: POSTGRESQL API'YE KAYDEDİLDİ! ✅✅✅");

          // Update UI immediately
          if (mounted) {
            setState(() {
              // Find and update the diary in the list
              for (int i = 0; i < diaries.length; i++) {
                String? entryId =
                    diaries[i]['id']?.toString() ??
                    diaries[i]['_id']?.toString();
                if (entryId == currentId) {
                  diaries[i]['advice'] = finalData['advice'] ?? '';
                  diaries[i]['analysis'] = finalData['analysis'] ?? '';
                  diaries[i]['mood'] = finalData['mood'] ?? 'Calm';
                  diaries[i]['has_advice'] = true; // PERMANENT
                  break;
                }
              }
            });
          }
        }
      }

      // Prepare data for navigation
      finalData['date'] = entry?['date'];
      finalData['formattedDate'] = entry != null
          ? _formatDate(entry['date'])
          : '';
      finalData['diary_id'] = currentId;
      finalData['has_advice'] = true; // Always true after getting advice
      finalData['character_type'] = type;
      finalData['sign'] = sign;
      finalData['mood'] ??= 'Calm';

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
