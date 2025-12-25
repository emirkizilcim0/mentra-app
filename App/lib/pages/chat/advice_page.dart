import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mentra_app/providers/theme_provider.dart';
import 'package:mentra_app/services/dairy/dairy_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'advice_view_body.dart';
import 'dart:math';
import 'package:mentra_app/services/dairy/dairy_auth.dart';
import 'advice_bottom_bar.dart';

class AdvicePage extends StatefulWidget {
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
  int _refreshTrigger = 0;

  @override
  void initState() {
    super.initState();
    print('🔍 AdvicePage initState called');
    print('   generatedAdvice: ${widget.generatedAdvice != null}');

    _loadAnalyses();
  }

  @override
  void didUpdateWidget(AdvicePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('🔄 AdvicePage didUpdateWidget - refreshing data');
    _loadAnalyses();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !isLoading) {
        _checkForNewAdvice();
      }
    });
  }

  Future<void> _checkForNewAdvice() async {
    print('🔄 Checking for new advice...');
    try {
      final freshCount = await _getFreshAnalysisCount();
      if (freshCount > analyses.length) {
        print(
          '📈 Found ${freshCount - analyses.length} new analyses, refreshing...',
        );
        _loadAnalyses();
      }
    } catch (e) {
      print('⚠️ Error checking for new advice: $e');
    }
  }

  Future<int> _getFreshAnalysisCount() async {
    try {
      // Get Firebase user ID
      final userId = DiaryAuth.getUserId();

      final response = await http.get(
        Uri.parse(
          'https://mentra-app-b2ei.onrender.com/analyses?user_id=$userId&limit=1',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data.length;
      }
    } catch (e) {
      print('⚠️ Error getting fresh count: $e');
    }
    return analyses.length;
  }

  Future<void> _loadAnalyses() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      print('📋 Loading analyses from DiaryService...');

      // Get analyses from service
      final items = await DiaryService.getAnalysisHistory(limit: 50);
      print('📊 Received ${items.length} items from getAnalysisHistory');

      // If no items, show empty state
      if (items.isEmpty) {
        print('📭 No analyses found');
        setState(() {
          analyses = [];
          isLoading = false;
        });
        return;
      }

      // If we have chat-generated advice, add it to the list
      if (widget.generatedAdvice != null &&
          widget.generatedAdvice!.isNotEmpty) {
        print('➕ Adding chat-generated advice to list');
        final chatAnalysis = {
          'analysis': widget.generatedAdvice,
          'advice': widget.generatedAdvice,
          'created_at': widget.date ?? DateTime.now().toIso8601String(),
          'date': widget.date ?? DateTime.now().toIso8601String(),
          'mood': 'Calm',
          'has_advice': true,
          'seen': false,
          'character_type': 'Chat Generated',
          'sign': 'Unknown',
          'is_new': true,
        };
        items.insert(0, chatAnalysis);
      }

      // Process all items
      final List<Map<String, dynamic>> processedItems = items.map((item) {
        final Map<String, dynamic> processed = Map<String, dynamic>.from(item);

        // ✅ FIX: Handle empty advice text properly
        String adviceText =
            processed['analysis']?.toString() ??
            processed['advice']?.toString() ??
            '';

        if (adviceText.trim().isEmpty) {
          print(
            '⚠️ Empty advice text found for item ${processed['id'] ?? 'unknown'}',
          );
          if (processed['content']?.toString().isNotEmpty == true) {
            adviceText =
                "Analysis of: ${processed['content']?.toString().substring(0, min(100, processed['content']?.toString().length ?? 0))}...";
          } else {
            adviceText = "Advice analysis will be available soon.";
          }
        }

        // Ensure both fields exist
        processed['analysis'] = adviceText;
        processed['advice'] = adviceText;

        // Ensure mood field exists
        if (!processed.containsKey('mood') ||
            processed['mood']?.toString().isEmpty == true) {
          processed['mood'] = 'Calm';
        }

        // Ensure seen field exists
        if (!processed.containsKey('seen')) {
          processed['seen'] = processed.containsKey('is_new') ? false : true;
        }

        // Ensure date field exists
        if (!processed.containsKey('date') &&
            processed.containsKey('created_at')) {
          processed['date'] = processed['created_at'];
        }

        // Create a formatted date for display
        if (processed.containsKey('date')) {
          try {
            String dateStr = processed['date'].toString();
            DateTime date;
            if (dateStr.contains('T')) {
              date = DateTime.parse(dateStr);
            } else {
              date = DateTime.parse('${dateStr}Z');
            }
            processed['formattedDate'] = DateFormat(
              'd MMMM yyyy',
              'en_US',
            ).format(date.toLocal());
          } catch (e) {
            final dateStr = processed['date'].toString();
            print('Date parse error for "$dateStr": $e');
            processed['formattedDate'] = 'Recent';
          }
        } else {
          processed['formattedDate'] = 'Recent';
        }

        return processed;
      }).toList();

      // Sort by date (newest first)
      processedItems.sort((a, b) {
        try {
          final dateA = a['date'] is String
              ? DateTime.parse(a['date'].toString())
              : DateTime.now();
          final dateB = b['date'] is String
              ? DateTime.parse(b['date'].toString())
              : DateTime.now();
          return dateB.compareTo(dateA);
        } catch (e) {
          return 0;
        }
      });

      print('✅ Processed ${processedItems.length} analyses');

      setState(() {
        analyses = processedItems;
        isLoading = false;
        _refreshTrigger++;
      });
    } catch (e) {
      print('❌ Error loading analyses: $e');
      setState(() {
        isLoading = false;
        errorMessage =
            "Advices aren't available at the moment. Please check your connection.";
      });
    }
  }

  Future<void> refreshData() async {
    print('🔄 Manual refresh triggered');
    await _loadAnalyses();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFE8F4F9),
      // Klasik AppBar kaldırıldı, body içinde Stack ile yönetiliyor
      body: Stack(
        children: [
          // 1. ANA İÇERİK
          Positioned.fill(
            child: RefreshIndicator(
              onRefresh: refreshData,
              // Top padding, yüzen kapsül barın altında kalmaması için artırıldı
              child: Padding(
                padding: const EdgeInsets.only(top: 110, bottom: 100),
                child: AdviceViewBody(
                  isLoading: isLoading,
                  errorMessage: errorMessage,
                  analyses: analyses,
                  isDark: isDark,
                ),
              ),
            ),
          ),

          // 2. ÜST YÜZEN BUTONLAR (Entegre edilen kısım)
          Positioned(
            top: statusBarHeight + 10,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Advice Yazısı Kapsülü
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.black : Colors.white)
                            .withOpacity(0.3),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withOpacity(isDark ? 0.2 : 0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.tips_and_updates_rounded,
                            color: isDark
                                ? Colors.amberAccent
                                : Colors.blueAccent,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Advice",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Refresh Butonu Kapsülü
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.black : Colors.white)
                            .withOpacity(0.3),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withOpacity(isDark ? 0.2 : 0.5),
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.refresh_rounded,
                          color: isDark ? Colors.white : Colors.black87,
                          size: 24,
                        ),
                        onPressed: refreshData,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. ALT BAR
          AdviceBottomBar(isDark: isDark),
        ],
      ),
    );
  }
}
