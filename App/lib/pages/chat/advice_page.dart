import 'package:flutter/material.dart';
import 'package:mentra_app/providers/theme_provider.dart';
import 'package:mentra_app/services/dairy/dairy_service.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'advice_view_body.dart';

class AdvicePage extends StatefulWidget {
  final String? generatedAdvice;
  final String? date;
  final Map<String, dynamic>?
  fullAnalysisData; // NEW: Accept full analysis data

  const AdvicePage({
    super.key,
    this.generatedAdvice,
    this.date,
    this.fullAnalysisData, // NEW
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
    _initializeData();
  }

  Future<void> _initializeData() async {
    // Always load history first
    await _loadAnalyses();

    // Then check if we have new generated advice to prepend
    if (widget.fullAnalysisData != null) {
      // Check if this analysis already exists in the list
      final existingIndex = analyses.indexWhere(
        (item) =>
            item['analysis_date'] ==
                widget.fullAnalysisData!['analysis_date'] ||
            (item['advice'] ?? '').contains(widget.generatedAdvice ?? ''),
      );

      if (existingIndex == -1) {
        // NEW: Add the full analysis data to the beginning
        setState(() {
          analyses.insert(0, widget.fullAnalysisData!);
        });
      }
    } else if (widget.generatedAdvice != null) {
      // Legacy support: If only generatedAdvice is provided
      final newAnalysis = {
        'analysis': widget.generatedAdvice,
        'advice': widget.generatedAdvice, // Add advice field for compatibility
        'created_at': widget.date ?? DateTime.now().toString(),
        'analysis_date': widget.date ?? DateTime.now().toString(),
        'is_new': true, // Flag to mark as new
      };

      setState(() {
        analyses.insert(0, newAnalysis);
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  // Update your _loadAnalyses() method in AdvicePage
  Future<void> _loadAnalyses() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      // FETCH FROM FIREBASE instead of PostgreSQL backend
      final List<Map<String, dynamic>> items = await _fetchFromFirebase();

      print('🔥 Loaded ${items.length} items from Firebase');

      // Rest of your existing code...
    } catch (e) {
      print("❌ Error loading analyses: $e");
      setState(() {
        isLoading = false;
        errorMessage = "Advices aren't available at the moment.";
        analyses = [];
      });
    }
  }

  // Add this method to fetch from Firebase
  Future<List<Map<String, dynamic>>> _fetchFromFirebase() async {
    try {
      // Get current user ID
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? 'unknown';

      // Fetch from Firebase 'analyses' collection
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('analyses')
          .where('user_id', isEqualTo: userId) // Add this field when saving!
          .orderBy('created_at', descending: true)
          .limit(50)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'analysis': data['advice'] ?? data['analysis'] ?? '',
          'advice': data['advice'] ?? data['analysis'] ?? '',
          'mood': data['mood'] ?? 'Calm',
          'character_type': data['character_type'] ?? 'Unknown',
          'sign': data['sign'] ?? 'Unknown',
          'date': data['created_at']?.toString() ?? DateTime.now().toString(),
          'created_at':
              data['created_at']?.toString() ?? DateTime.now().toString(),
          'analysis_date':
              data['created_at']?.toString() ?? DateTime.now().toString(),
        };
      }).toList();
    } catch (e) {
      print('❌ Error fetching from Firebase: $e');
      return [];
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
            onPressed: () {
              setState(() {
                isLoading = true;
              });
              _initializeData();
            },
            icon: const Icon(Icons.refresh),
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
