import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mentra_app/providers/theme_provider.dart';
import 'package:mentra_app/services/dairy/dairy_service.dart'; // ADD THIS IMPORT
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'advice_colors.dart';
import 'advice_utils.dart';
import 'comp_card.dart';
import 'comp_date.dart';
import 'comp_title.dart';
import 'comp_body.dart';

class AdviceDetailPage extends StatefulWidget {
  // CHANGED to StatefulWidget
  final Map<String, dynamic> analysisItem;
  final String title;
  final bool shouldSaveToHistory; // NEW: Control whether to save

  const AdviceDetailPage({
    super.key,
    required this.analysisItem,
    required this.title,
    this.shouldSaveToHistory = false, // NEW: Default is false
  });

  @override
  State<AdviceDetailPage> createState() => _AdviceDetailPageState();
}

class _AdviceDetailPageState extends State<AdviceDetailPage> {
  bool _hasSaved = false;

  Future<String> _getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check for user_id in different possible keys
      final userId =
          prefs.getString('user_id') ??
          prefs.getString('uid') ??
          prefs.getString('userId') ??
          'unknown_user';

      print('🔑 Retrieved user_id from SharedPreferences: $userId');
      return userId;
    } catch (e) {
      print('❌ Error getting user_id from SharedPreferences: $e');
      return 'unknown_user';
    }
  }

  @override
  void initState() {
    super.initState();
    // Save to history when the page opens (if needed)
    if (widget.shouldSaveToHistory && !_hasSaved) {
      _saveToHistory();
    }
  }

  Future<void> _saveToHistory() async {
    try {
      // Check if this analysis already exists to avoid duplicates
      final history = await DiaryService.getAnalysisHistory(limit: 50);
      final currentDate =
          widget.analysisItem['analysis_date'] ??
          widget.analysisItem['date'] ??
          DateTime.now().toString();

      // Check for duplicates based on date/content
      final isDuplicate = history.any((item) {
        final itemDate = item['date'] ?? item['analysis_date'] ?? '';
        final itemAdvice = item['advice'] ?? item['analysis'] ?? '';
        final currentAdvice =
            widget.analysisItem['advice'] ??
            widget.analysisItem['analysis'] ??
            '';

        return itemDate.contains(currentDate.substring(0, 10)) || // Check date
            itemAdvice.contains(
              currentAdvice.substring(0, 50),
            ); // Check content
      });

      if (!isDuplicate) {
        // Prepare analysis data for saving
        final Map<String, dynamic> analysisData = {
          'character_type': widget.analysisItem['character_type'] ?? 'Unknown',
          'sign': widget.analysisItem['sign'] ?? 'Unknown',
          'birth_map': widget.analysisItem['birth_map'] ?? 'Not specified',
          'mood': widget.analysisItem['mood'] ?? 'Calm',
          'advice':
              widget.analysisItem['advice'] ??
              widget.analysisItem['analysis'] ??
              '',
          'analysis':
              widget.analysisItem['analysis'] ??
              widget.analysisItem['advice'] ??
              '',
          'analysis_date': currentDate,
        };

        // Save via backend API
        // Note: This assumes your backend has an endpoint to save analyses
        // If not, you might need to save to local storage or Firebase
        await _saveAnalysisToBackend(analysisData);

        setState(() {
          _hasSaved = true;
        });

        print('✅ Analysis saved to history');
      } else {
        print('ℹ️ Analysis already exists in history');
      }
    } catch (e) {
      print('❌ Error saving to history: $e');
    }
  }

  Future<void> _saveAnalysisToBackend(Map<String, dynamic> analysisData) async {
    try {
      // IMPORTANT: You need to implement this method in DiaryService first!
      // This sends the analysis to your backend to save in PostgreSQL

      print('📤 Attempting to save analysis to backend...');
      print('📋 Analysis data: $analysisData');

      // Option 1: Call your existing save endpoint (if it exists)
      // You need to create this method in DiaryService first!
      // await DiaryService.saveAnalysis(analysisData);

      // Option 2: Save directly via HTTP (immediate fix)
      await _saveViaHttp(analysisData);
    } catch (e) {
      print('❌ Error in _saveAnalysisToBackend: $e');
      // Fallback: Save to local storage as temporary backup
      await _saveToLocalStorage(analysisData);
    }
  }

  // Direct HTTP save method
  Future<void> _saveViaHttp(Map<String, dynamic> analysisData) async {
    try {
      // Get your backend URL and user ID
      final baseUrl = 'https://mentra-app.onrender.com'; // UPDATE THIS
      final userId = await _getUserId(); // Get from SharedPreferences

      // Create the request
      final response = await http.post(
        Uri.parse('$baseUrl/analyses/save'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'character_type': analysisData['character_type'],
          'sign': analysisData['sign'],
          'birth_map': analysisData['birth_map'],
          'advice': analysisData['advice'],
          'mood': analysisData['mood'],
          'analysis_date': analysisData['analysis_date'],
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Analysis saved via HTTP to PostgreSQL');
      } else {
        print('❌ HTTP save failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ HTTP save error: $e');
      rethrow;
    }
  }

  // Fallback local storage
  Future<void> _saveToLocalStorage(Map<String, dynamic> analysisData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> history = prefs.getStringList('local_analyses') ?? [];

      history.add(
        json.encode({
          ...analysisData,
          'saved_locally_at': DateTime.now().toString(),
        }),
      );

      await prefs.setStringList('local_analyses', history);
      print('✅ Analysis saved to local storage as backup');
    } catch (e) {
      print('❌ Local storage save error: $e');
    }
  }

  String _formatDateUS(Map<String, dynamic> item) {
    final rawDate = item['formattedDate'] ?? item['created_at'] ?? item['date'];

    if (rawDate == null) return '';

    try {
      DateTime date;
      if (rawDate is DateTime) {
        date = rawDate;
      } else {
        date = DateTime.parse(rawDate.toString());
      }
      return DateFormat('d MMMM, yyyy', 'en_US').format(date.toLocal());
    } catch (_) {
      return rawDate.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final mood = widget.analysisItem['mood'] ?? 'Calm';
    final emoji = _getEmojiForMood(mood);
    final moodColor = _getMoodColor(mood);
    final formattedDate = _formatDateUS(widget.analysisItem);

    return Scaffold(
      backgroundColor: AdviceColors.bg(isDark),
      appBar: AppBar(
        title: const Text('Advice'),
        actions: [
          // Optional: Add a save button for manual saving
          if (widget.shouldSaveToHistory && !_hasSaved)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveToHistory,
              tooltip: 'Save to history',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Mood indicator
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: moodColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: moodColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: moodColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Text(emoji, style: const TextStyle(fontSize: 32)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Mood: $mood',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: moodColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white70 : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Diaries analyzed: ${widget.analysisItem['diaries_analyzed'] ?? 0}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white60 : Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            CompCard(
              isDark: isDark,
              children: [
                CompDate(date: formattedDate, isDark: isDark),
                const SizedBox(height: 10),
                CompTitle(title: widget.title, isDark: isDark),
                const SizedBox(height: 16),
                CompBody(
                  text: AdviceUtils.getAdvice(widget.analysisItem),
                  isDark: isDark,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Analysis details section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Analysis Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    'Character Type',
                    widget.analysisItem['character_type'] ?? 'Not specified',
                    isDark,
                  ),
                  _buildDetailRow(
                    'Zodiac Sign',
                    widget.analysisItem['sign'] ?? 'Not specified',
                    isDark,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return Colors.green;
      case 'sad':
        return Colors.blue;
      case 'anxious':
        return Colors.orange;
      case 'angry':
        return Colors.red;
      case 'calm':
        return Colors.blueAccent;
      case 'confused':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }

  String _getEmojiForMood(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return '😊';
      case 'sad':
        return '😢';
      case 'anxious':
        return '😰';
      case 'angry':
        return '😠';
      case 'calm':
        return '😌';
      case 'confused':
        return '😕';
      default:
        return '😊';
    }
  }
}
