import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'diary_write_page.dart';
import 'diary_detail_page.dart';
import 'services/diary_service.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<Map<String, dynamic>> diaryEntries = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDiaryEntries();
  }

  // Load diaries from FastAPI backend
  Future<void> _loadDiaryEntries() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final entries = await DiaryService.getDiaryEntries();
      setState(() {
        diaryEntries = entries;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading diary entries: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load diaries. Please check your connection.';
      });
    }
  }

  Future<void> _openDiaryWritePage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DiaryWritePage()),
    );

    if (result != null && result is Map<String, dynamic>) {
      try {
        await DiaryService.saveDiaryEntry(result);
        _loadDiaryEntries(); // Reload the list

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Diary saved successfully!')),
        );
      } catch (e) {
        print('Error saving diary entry: $e');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving diary: $e')));
      }
    }
  }

  void _openDiaryDetail(Map<String, dynamic> entry) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiaryDetailPage(diaryEntry: entry),
      ),
    );
  }

  Future<void> _getPsychologicalAdvice() async {
    try {
      // You'll need to get these from user profile
      final analysis = await DiaryService.analyzeDiaries(
        characterType: 'INTP', // Get from user profile
        sign: 'Scorpio', // Get from user profile
        birthMap: 'Sun in Scorpio, Moon in Cancer', // Get from user profile
        diaryCount: 5,
      );

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Your Psychological Analysis'),
          content: SingleChildScrollView(child: Text(analysis['advice'])),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error getting analysis: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F4F9),
      body: SafeArea(
        child: Column(
          children: [
            // 🩶 Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Mentra",
                    style: GoogleFonts.pacifico(
                      fontSize: 28,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.psychology_outlined),
                    onPressed: _getPsychologicalAdvice,
                    tooltip: 'Get Psychological Analysis',
                  ),
                ],
              ),
            ),

            // ✍️ Write Diary Button
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(40),
              ),
              child: InkWell(
                onTap: _openDiaryWritePage,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Write diary",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.edit, color: Colors.white),
                  ],
                ),
              ),
            ),

            // 🕓 Previous Diaries Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Your previous diaries",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _loadDiaryEntries,
                    tooltip: 'Refresh diaries',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Error message
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),

            // 📅 List of previous diary dates
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 10,
                ),
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : diaryEntries.isEmpty
                    ? Column(
                        children: [
                          const SizedBox(height: 50),
                          Icon(
                            Icons.edit_note,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No diary entries yet.\nStart writing your first diary!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: diaryEntries.map((entry) {
                          return Container(
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: InkWell(
                              onTap: () => _openDiaryDetail(entry),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      entry['formattedDate'] ?? 'No date',
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  if (entry['mood'] != null &&
                                      entry['mood'].isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getMoodColor(entry['mood']),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        entry['mood'],
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
              ),
            ),

            // ⚙️ Bottom Navigation Bar
            Container(
              height: 65,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFCAE4EB), Color(0xFFE8F4F9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.home_outlined,
                      size: 28,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomePage(),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.person_outline,
                      size: 28,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfilePage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return Colors.green;
      case 'sad':
        return Colors.blue;
      case 'excited':
        return Colors.orange;
      case 'calm':
        return Colors.purple;
      case 'anxious':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
