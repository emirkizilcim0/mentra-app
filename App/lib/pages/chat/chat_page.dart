import 'package:flutter/material.dart';
import 'package:mentra_app/pages/dairy/write/dairy_write_page.dart';
import 'package:mentra_app/providers/theme_provider.dart';
import 'package:mentra_app/services/dairy/dairy_service.dart';
import 'package:provider/provider.dart';
import 'package:mentra_app/pages/advice/details/advice_details_page.dart';
import 'advice_utils.dart';
import 'package:intl/intl.dart';
import '../home/loading_view.dart';
import 'logic_data.dart';
import 'logic_nav.dart';
import 'chat_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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

  Future<String> _getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId =
          prefs.getString('user_id') ??
          prefs.getString('uid') ??
          prefs.getString('userId') ??
          'unknown_user';
      return userId;
    } catch (e) {
      return 'unknown_user';
    }
  }

  // --- CRITICAL FIX: Save to PostgreSQL PROPERLY ---
  Future<void> _saveToPostgreSQL(
    Map<String, dynamic> analysisData,
    String? diaryId,
    Map<String, dynamic>? entry,
  ) async {
    try {
      final userId = await _getUserId();
      final baseUrl = 'https://mentra-app.onrender.com';

      print('📤 SAVING TO POSTGRESQL for user: $userId');

      // Save via /analyses/save endpoint (your new endpoint)
      final response = await http.post(
        Uri.parse('$baseUrl/analyses/save'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'character_type': type,
          'sign': sign,
          'birth_map': 'Not specified',
          'advice': analysisData['advice'] ?? '',
          'mood': analysisData['mood'] ?? 'Calm',
          'analysis_date': DateTime.now().toIso8601String(),
          'diary_id': diaryId,
        }),
      );

      if (response.statusCode == 200) {
        print('✅✅✅ POSTGRESQL SAVE SUCCESSFUL ✅✅✅');
        print('📊 Response: ${response.body}');
      } else {
        print(
          '⚠️ PostgreSQL save failed: ${response.statusCode} - ${response.body}',
        );

        // Fallback: Try the old /analyze/diaries endpoint
        await http.post(
          Uri.parse('$baseUrl/analyze/diaries'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'user_id': userId,
            'character_type': type,
            'sign': sign,
            'birth_map': 'Not specified',
            'diary_count': 1,
            'specific_content': entry != null
                ? (entry['content'] ?? entry['text'] ?? "")
                : null,
          }),
        );
        print('🔄 Used fallback /analyze/diaries endpoint');
      }
    } catch (e) {
      print('❌ PostgreSQL save error: $e');
    }
  }

  Future<void> _loadDiaries() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      print('🔄 Loading diaries from PostgreSQL...');

      // Get user ID
      final userId = await _getUserId();
      final baseUrl = 'https://mentra-app.onrender.com';

      // Try to load diaries from LogicData first (or directly from PostgreSQL)
      List<Map<String, dynamic>> items = [];

      try {
        // Option 1: Use your existing LogicData.loadDiaries()
        items = await LogicData.loadDiaries();
        print('📝 Loaded ${items.length} diaries from LogicData');

        // If LogicData returns empty, try direct PostgreSQL API
        if (items.isEmpty) {
          print('⚠️ LogicData returned empty, trying direct API...');
          final response = await http.get(
            Uri.parse('$baseUrl/diaries/$userId'),
          );

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            if (data['diaries'] is List) {
              items = (data['diaries'] as List).cast<Map<String, dynamic>>();
              print('📝 Direct API loaded ${items.length} diaries');
            }
          }
        }
      } catch (e) {
        print('⚠️ Diary loading error: $e');
        // Continue with empty items
      }

      // Load analyses from PostgreSQL
      print('🔍 Loading analyses from PostgreSQL...');
      final analysisResponse = await http.get(
        Uri.parse('$baseUrl/analysis/history/$userId?limit=100'),
      );

      Map<String, Map<String, dynamic>> analysisMap = {};

      if (analysisResponse.statusCode == 200) {
        final analysisData = json.decode(analysisResponse.body);
        print('📊 Analysis response keys: ${analysisData.keys}');

        if (analysisData['analyses'] is List) {
          final analyses = (analysisData['analyses'] as List)
              .cast<Map<String, dynamic>>();
          print('✅ Found ${analyses.length} analyses');

          // Create map: diary_id -> analysis
          for (var analysis in analyses) {
            final diaryId = analysis['diary_id']?.toString();
            if (diaryId != null && diaryId.isNotEmpty) {
              analysisMap[diaryId] = analysis;
              print('📌 Mapped analysis to diary_id: $diaryId');
            }
          }
        }
      } else {
        print('⚠️ Failed to load analyses: ${analysisResponse.statusCode}');
      }

      // Process each diary
      for (var item in items) {
        // Format date
        if (item['date'] != null) {
          item['formattedDate'] = _formatDate(item['date']);
        }

        // Get diary ID (try multiple possible field names)
        final diaryId =
            item['id']?.toString() ??
            item['_id']?.toString() ??
            item['diary_id']?.toString() ??
            '';

        print('🔍 Processing diary ID: $diaryId');

        // Attach analysis if exists
        if (analysisMap.containsKey(diaryId)) {
          final analysis = analysisMap[diaryId]!;
          item['advice'] = analysis['advice'] ?? analysis['analysis'] ?? '';
          item['analysis'] = analysis['analysis'] ?? analysis['advice'] ?? '';
          item['mood'] = analysis['mood'] ?? 'Calm';
          print('✅ Attached advice to diary $diaryId');
        } else {
          // Clear any old advice
          item['advice'] = null;
          item['analysis'] = null;
          item['mood'] = null;
        }
      }

      setState(() {
        diaries = items;
        loading = false;
        print(
          '🎉 Loaded ${items.length} diaries with ${analysisMap.length} analyses attached',
        );
      });

      // Handle auto-open logic
      if (mounted && widget.selectedDate != null && widget.showAdvice) {
        String y = widget.selectedDate!.year.toString();
        String m = widget.selectedDate!.month.toString().padLeft(2, '0');
        String d = widget.selectedDate!.day.toString().padLeft(2, '0');
        String targetKey = "$y-$m-$d";

        final foundEntry = items.firstWhere((e) {
          final dateStr = e['date']?.toString() ?? '';
          return dateStr.contains(targetKey);
        }, orElse: () => {});

        if (foundEntry.isNotEmpty) {
          _getAdvice(foundEntry);
        } else {
          _getAdvice(null);
        }
      } else if (mounted) {
        LogicNav.checkForAutoOpen(
          context,
          widget.selectedDate,
          items,
          Provider.of<ThemeProvider>(context, listen: false).isDarkMode,
        );
      }
    } catch (e) {
      print("❌ Load Error: $e");
      setState(() {
        loading = false;
        error = 'Failed to load diaries. Please try again.';
      });
    }
  }

  // --- COMPLETELY FIXED _getAdvice FUNCTION ---
  Future<void> _getAdvice(Map<String, dynamic>? entry) async {
    setState(() {
      _isAnalyzing = true;
    });

    print("📢 1. START: _getAdvice called.");

    try {
      // If advice already exists, open it directly
      if (entry != null &&
          entry['advice'] != null &&
          entry['advice'].toString().isNotEmpty) {
        print("📢 2. STATUS: Advice already exists, opening directly.");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdviceDetailPage(
              analysisItem: entry,
              title: "Daily Advice",
              shouldSaveToHistory: false,
            ),
          ),
        );
        setState(() {
          _isAnalyzing = false;
        });
        return;
      }

      String? currentId;
      String? diaryContent;

      if (entry != null) {
        currentId = entry['id']?.toString() ?? entry['_id']?.toString();
        diaryContent = entry['content'] ?? entry['text'] ?? "";
      }

      print("📢 3. ID DETECTION: Processing ID: $currentId");

      // AI Analysis
      print("📢 4. STATUS: Calling AI service...");
      final Map<String, dynamic> response = await DiaryService.analyzeDiaries(
        characterType: type,
        sign: sign,
        birthMap: 'Not specified',
        diaryCount: 1,
        specificContent: diaryContent,
        specificIds: currentId != null ? [currentId] : null,
        userDiaries: entry != null ? [entry] : null,
      );
      print("📢 5. STATUS: AI response received.");

      final Map<String, dynamic> finalData = Map.of(response);

      // --- POSTGRESQL SAVE ONLY ---
      if (entry != null && currentId != null) {
        print("📢 6. STATUS: Saving to PostgreSQL...");

        try {
          final userId = await _getUserId();
          final baseUrl = 'https://mentra-app.onrender.com';

          // Save analysis to PostgreSQL
          final saveResponse = await http.post(
            Uri.parse('$baseUrl/analyses/save'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'user_id': userId,
              'character_type': type,
              'sign': sign,
              'birth_map': 'Not specified',
              'advice': finalData['advice'] ?? '',
              'analysis': finalData['analysis'] ?? finalData['advice'] ?? '',
              'mood': finalData['mood'] ?? 'Calm',
              'analysis_date': DateTime.now().toIso8601String(),
              'diary_id': currentId,
              'diaries_analyzed': 1,
            }),
          );

          if (saveResponse.statusCode == 200) {
            print("✅✅✅ SAVED TO POSTGRESQL SUCCESSFULLY! ✅✅✅");

            // Store the saved analysis ID if returned
            try {
              final responseData = json.decode(saveResponse.body);
              if (responseData['id'] != null) {
                finalData['id'] = responseData['id'].toString();
              }
            } catch (e) {
              print("Note: Could not parse save response: $e");
            }
          } else {
            print(
              "⚠️ PostgreSQL save failed: ${saveResponse.statusCode} - ${saveResponse.body}",
            );

            // Alternative save method if primary endpoint fails
            try {
              await http.post(
                Uri.parse('$baseUrl/analyze/diaries'),
                headers: {'Content-Type': 'application/json'},
                body: json.encode({
                  'user_id': userId,
                  'character_type': type,
                  'sign': sign,
                  'birth_map': 'Not specified',
                  'diary_count': 1,
                  'specific_content': diaryContent,
                  'specific_ids': [currentId],
                }),
              );
              print("🔄 Used alternative /analyze/diaries endpoint");
            } catch (fallbackError) {
              print("❌ Fallback save also failed: $fallbackError");
            }
          }
        } catch (postgresError) {
          print("❌❌❌ POSTGRESQL ERROR: $postgresError ❌❌❌");
        }
      }

      // Prepare data for display
      if (entry != null) {
        finalData['date'] = entry['date'];
        finalData['formattedDate'] = _formatDate(entry['date']);
        if (currentId != null) {
          finalData['diary_id'] = currentId;
        }
      }

      finalData['character_type'] = type;
      finalData['sign'] = sign;
      finalData['mood'] = finalData['mood'] ?? 'Calm';
      finalData['diaries_analyzed'] = 1;
      finalData['analysis_date'] = DateTime.now().toIso8601String();

      // If we have a saved ID from PostgreSQL, use it
      if (finalData['id'] == null && entry != null) {
        finalData['id'] = 'temp_${DateTime.now().millisecondsSinceEpoch}';
      }

      // Refresh diaries to show the new advice button
      await _loadDiaries();

      // Open AdviceDetailPage
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
              shouldSaveToHistory: true,
            ),
          ),
        );
      }
    } catch (e) {
      print("❌❌❌ GENERAL ERROR: $e ❌❌❌");
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  Future<void> _write() async {
    final res = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DiaryWritePage()),
    );

    if (res != null) {
      // Save to PostgreSQL via your backend
      final userId = await _getUserId();
      try {
        await http.post(
          Uri.parse(
            'https://mentra-app.onrender.com/diaries/save?user_id=$userId',
          ),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'content': res['content'] ?? res['text'] ?? '',
            'mood': res['mood'],
            'tags': res['tags'],
          }),
        );
        print('✅ Diary saved to PostgreSQL');
      } catch (e) {
        print('❌ PostgreSQL diary save error: $e');
      }

      // Also save to Firebase for compatibility
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
