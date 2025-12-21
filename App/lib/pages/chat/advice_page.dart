import 'package:flutter/material.dart';
import 'package:mentra_app/providers/theme_provider.dart';
import 'package:mentra_app/services/dairy/dairy_service.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'advice_view_body.dart';

class AdvicePage extends StatefulWidget {
  final String? generatedAdvice;
  final String? date;
  final Map<String, dynamic>? fullAnalysisData;

  const AdvicePage({
    super.key,
    this.generatedAdvice,
    this.date,
    this.fullAnalysisData,
  });

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

  // Helper to get user ID
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

  // FIXED: Proper PostgreSQL loading
  Future<void> _loadAnalyses() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      print('📊 Loading analyses from PostgreSQL...');

      // OPTION 1: Use DiaryService (if it's working with PostgreSQL)
      try {
        final items = await DiaryService.getAnalysisHistory(limit: 50);
        print('✅ Loaded ${items.length} items via DiaryService');

        if (items.isEmpty) {
          // If DiaryService returns empty, try direct API call
          await _loadDirectFromApi();
        } else {
          _processAndDisplayItems(items);
        }
      } catch (e) {
        print('⚠️ DiaryService failed, trying direct API: $e');
        await _loadDirectFromApi();
      }
    } catch (e) {
      print("❌ Error loading analyses: $e");
      setState(() {
        isLoading = false;
        errorMessage = "Unable to load advices. Please try again.";
        analyses = [];
      });
    }
  }

  // Direct API call to PostgreSQL backend
  Future<void> _loadDirectFromApi() async {
    try {
      final userId = await _getUserId();
      final baseUrl = 'https://mentra-app.onrender.com';

      print('🌐 Direct API call for user: $userId');

      // Try the analyses endpoint first
      final response = await http
          .get(
            Uri.parse('$baseUrl/analyses/user/$userId'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('✅ Direct API loaded ${data.length} items');
        _processAndDisplayItems(data.cast<Map<String, dynamic>>());
      } else {
        // Try alternative endpoints
        await _tryAlternativeEndpoints(userId);
      }
    } catch (e) {
      print('❌ Direct API call failed: $e');
      throw e;
    }
  }

  // Try alternative endpoints
  Future<void> _tryAlternativeEndpoints(String userId) async {
    final baseUrl = 'https://mentra-app.onrender.com';
    final endpoints = [
      '$baseUrl/analyses?user_id=$userId',
      '$baseUrl/analyses',
      '$baseUrl/analysis-history?user_id=$userId',
    ];

    for (final endpoint in endpoints) {
      try {
        print('🔄 Trying endpoint: $endpoint');
        final response = await http
            .get(Uri.parse(endpoint), headers: {'Accept': 'application/json'})
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          List<Map<String, dynamic>> items;

          if (data is List) {
            items = data.cast<Map<String, dynamic>>();
          } else if (data is Map && data['analyses'] is List) {
            items = (data['analyses'] as List).cast<Map<String, dynamic>>();
          } else {
            items = [];
          }

          print('✅ Endpoint $endpoint loaded ${items.length} items');
          _processAndDisplayItems(items);
          return;
        }
      } catch (e) {
        print('⚠️ Endpoint $endpoint failed: $e');
      }
    }

    throw Exception('All endpoints failed');
  }

  // Process items for display
  void _processAndDisplayItems(List<Map<String, dynamic>> items) {
    final List<Map<String, dynamic>> processedItems = [];

    for (var item in items) {
      // Debug print for first item
      if (processedItems.isEmpty) {
        print('🔍 Raw item structure:');
        item.forEach((key, value) {
          if (value != null) {
            print(
              '   $key: ${value.toString().length > 50 ? '${value.toString().substring(0, 50)}...' : value}',
            );
          }
        });
      }

      // Process item for display
      final processedItem = {
        'id': item['id']?.toString() ?? item['_id']?.toString() ?? '',
        'advice': item['advice']?.toString() ?? '',
        'analysis':
            item['analysis']?.toString() ?? item['advice']?.toString() ?? '',
        'mood': item['mood']?.toString() ?? 'Calm',
        'character_type':
            item['character_type']?.toString() ??
            item['characterType']?.toString() ??
            'Unknown',
        'sign': item['sign']?.toString() ?? 'Unknown',
        'date':
            item['analysis_date'] ??
            item['date'] ??
            item['created_at'] ??
            DateTime.now().toString(),
        'formattedDate': _formatDate(
          item['analysis_date'] ?? item['date'] ?? item['created_at'],
        ),
        'created_at':
            item['created_at']?.toString() ?? DateTime.now().toString(),
        'analysis_date':
            item['analysis_date']?.toString() ??
            item['date']?.toString() ??
            DateTime.now().toString(),
        'diaries_analyzed': (item['diaries_analyzed'] ?? 1) as int,
        'is_new': false,
      };
      processedItems.add(processedItem);
    }

    // Sort by date (newest first)
    processedItems.sort((a, b) {
      try {
        final dateA = DateTime.parse(a['analysis_date']?.toString() ?? '');
        final dateB = DateTime.parse(b['analysis_date']?.toString() ?? '');
        return dateB.compareTo(dateA);
      } catch (e) {
        return 0;
      }
    });

    // Add new analysis if provided
    if (widget.fullAnalysisData != null) {
      final newAnalysis = {
        'id':
            widget.fullAnalysisData!['id']?.toString() ??
            'new_${DateTime.now().millisecondsSinceEpoch}',
        'advice':
            widget.fullAnalysisData!['advice']?.toString() ??
            widget.generatedAdvice ??
            '',
        'analysis':
            widget.fullAnalysisData!['analysis']?.toString() ??
            widget.fullAnalysisData!['advice']?.toString() ??
            widget.generatedAdvice ??
            '',
        'mood': widget.fullAnalysisData!['mood']?.toString() ?? 'Calm',
        'character_type':
            widget.fullAnalysisData!['character_type']?.toString() ?? 'Unknown',
        'sign': widget.fullAnalysisData!['sign']?.toString() ?? 'Unknown',
        'date':
            widget.fullAnalysisData!['date']?.toString() ??
            widget.date ??
            DateTime.now().toString(),
        'formattedDate': _formatDate(
          widget.fullAnalysisData!['date'] ?? widget.date,
        ),
        'created_at':
            widget.fullAnalysisData!['created_at']?.toString() ??
            DateTime.now().toString(),
        'analysis_date':
            widget.fullAnalysisData!['analysis_date']?.toString() ??
            DateTime.now().toString(),
        'diaries_analyzed':
            (widget.fullAnalysisData!['diaries_analyzed'] ?? 1) as int,
        'is_new': true,
      };

      // Check if it already exists
      final exists = processedItems.any(
        (item) =>
            item['id'] == newAnalysis['id'] ||
            (item['advice'] == newAnalysis['advice'] &&
                item['date'] == newAnalysis['date']),
      );

      if (!exists) {
        processedItems.insert(0, newAnalysis);
      }
    }

    print('📈 Total analyses to display: ${processedItems.length}');

    setState(() {
      analyses = processedItems;
      isLoading = false;
    });
  }

  // Helper to format date
  String _formatDate(dynamic dateStr) {
    if (dateStr == null) return "Today";
    try {
      DateTime date;
      if (dateStr is DateTime) {
        date = dateStr;
      } else {
        date = DateTime.parse(dateStr.toString());
      }

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final dateOnly = DateTime(date.year, date.month, date.day);

      if (dateOnly == today) return "Today";
      if (dateOnly == yesterday) return "Yesterday";

      return "${date.day} ${_getMonthName(date.month)} ${date.year}";
    } catch (e) {
      return dateStr.toString();
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  void _debugAnalyses() {
    print('=== DEBUG ANALYSES ===');
    print('Total: ${analyses.length}');

    if (analyses.isNotEmpty) {
      for (int i = 0; i < analyses.length && i < 3; i++) {
        print('Analysis ${i + 1}:');
        print('  ID: ${analyses[i]['id']}');
        print('  Advice exists: ${analyses[i]['advice']?.isNotEmpty ?? false}');
        print('  Mood: ${analyses[i]['mood']}');
        print('  Date: ${analyses[i]['date']}');
        print('  Formatted: ${analyses[i]['formattedDate']}');
      }
    } else {
      print('No analyses found!');
      print('Checking DiaryService...');
      _testDiaryService();
    }

    print('======================');
  }

  Future<void> _testDiaryService() async {
    try {
      print('🧪 Testing DiaryService.getAnalysisHistory()...');
      final testItems = await DiaryService.getAnalysisHistory(limit: 5);
      print('🧪 DiaryService returned ${testItems.length} items');
      if (testItems.isNotEmpty) {
        print('🧪 First item keys: ${testItems[0].keys}');
      }
    } catch (e) {
      print('🧪 DiaryService test error: $e');
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
          IconButton(
            onPressed: _debugAnalyses,
            icon: const Icon(Icons.bug_report),
            tooltip: 'Debug',
          ),
          IconButton(
            onPressed: _loadAnalyses,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
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
