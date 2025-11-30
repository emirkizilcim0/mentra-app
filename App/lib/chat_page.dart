import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'diary_write_page.dart';
import 'diary_detail_page.dart';
import 'services/diary_service.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'advice_detail_page.dart';

// Varsayılan AdvicePage tanımı
class AdvicePage extends StatefulWidget {
  const AdvicePage({super.key});
  @override
  State<AdvicePage> createState() => _AdvicePageState();
}

class _AdvicePageState extends State<AdvicePage> {
  List<Map<String, dynamic>> analyses = [];
  bool isLoading = true;
  String? errorMessage;

  int _estimateHappinessPercent(String text) {
    if (text.isEmpty) return 50;
    final lower = text.toLowerCase();
    final positives = [
      'happy',
      'joy',
      'great',
      'good',
      'love',
      'wonderful',
      'optimistic',
      'positive',
      'success',
      'calm',
      'peace',
      'glad',
      'smile',
    ];
    final negatives = [
      'sad',
      'anxious',
      'worry',
      'stress',
      'angry',
      'bad',
      'pain',
      'cry',
      'depress',
      'fear',
      'lonely',
      'tired',
      'hopeless',
    ];
    int p = 0;
    int n = 0;
    for (final w in positives) {
      if (lower.contains(w)) p++;
    }
    for (final w in negatives) {
      if (lower.contains(w)) n++;
    }
    final score = (p - n).clamp(-10, 10);
    final percent = ((score + 10) * 5).toInt();
    return percent.clamp(0, 100);
  }

  String _emojiFor(int percent) {
    if (percent >= 75) return '😄';
    if (percent >= 50) return '😐';
    if (percent >= 25) return '😕';
    return '😭';
  }

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
        errorMessage = 'Tavsiyeler yüklenemedi.';
      });
    }
  }

  String _titleFromAdvice(String advice) {
    final text = advice.trim();
    if (text.isEmpty) return 'Advice';
    final dot = text.indexOf('.');
    final first = dot > 0 ? text.substring(0, dot) : text.split('\n').first;
    return first.length <= 60 ? first : '${first.substring(0, 60)}...';
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: themeProvider.isDarkMode
          ? const Color(0xFF121212)
          : const Color(0xFFE8F4F9),
      appBar: AppBar(
        title: const Text('Advice'),
        actions: [
          IconButton(onPressed: _loadAnalyses, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(
              child: Text(
                errorMessage!,
                style: TextStyle(
                  color: themeProvider.isDarkMode
                      ? Colors.redAccent[100]
                      : Colors.redAccent,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: analyses.length,
              itemBuilder: (context, index) {
                final item = analyses[index];
                final dateText = item['formattedDate'] ?? item['date'] ?? '';
                final adviceText = item['advice'] ?? '';
                final title = _titleFromAdvice(adviceText);
                final percent = _estimateHappinessPercent(adviceText);
                final emoji = _emojiFor(percent);
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AdviceDetailPage(analysisItem: item, title: title),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: themeProvider.isDarkMode
                          ? const Color(0xFF1E1E1E)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: themeProvider.isDarkMode
                            ? Colors.grey.shade700
                            : Colors.black12,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: themeProvider.isDarkMode
                              ? Colors.black54
                              : Colors.black12,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dateText,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: themeProvider.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: themeProvider.isDarkMode
                                      ? Colors.white70
                                      : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: themeProvider.isDarkMode
                                ? Colors.yellow.shade800
                                : Colors.yellow.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// Parametre alabilmesi için StatelessWidget yerine StatefulWidget'a dönüştürülmüştü.
// Şimdi parametreyi ekliyoruz.
class ChatPage extends StatefulWidget {
  // HomePage'den gönderilen seçili tarih (opsiyonel yapıyoruz, normalde null da gelebilir)
  final DateTime? selectedDate;

  const ChatPage({super.key, this.selectedDate});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<Map<String, dynamic>> diaryEntries = [];
  bool isLoading = true;
  bool isLoadingAdvice = false;
  String? errorMessage;

  // User data from Firebase
  String userName = "User";
  String userSign = "";
  String userCharacterType = "";

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadDiaryEntries();
    // NOT: _loadDiaryEntries() bittiğinde otomatik açma işlemi tetiklenecek
  }

  String _titleFromContent(String content) {
    final text = content.trim();
    if (text.isEmpty) return 'Untitled';
    final dot = text.indexOf('.');
    final first = dot > 0 ? text.substring(0, dot) : text.split('\n').first;
    return first.length <= 60 ? first : '${first.substring(0, 60)}...';
  }

  // Load user data from Firebase
  Future<void> _loadUserData() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();

        if (doc.exists) {
          final data = doc.data()!;
          setState(() {
            // Combine first + last name
            final firstName = data['firstName'] ?? "";
            final lastName = data['lastName'] ?? "";
            userName = "$firstName $lastName".trim();
            if (userName.isEmpty) userName = "User";

            // Zodiac sign
            userSign = data['zodiac'] ?? "";

            // MBTI/Character type
            userCharacterType = data['mbtiType'] ?? "";
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
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

      // === YENİ EK: Yükleme bittikten sonra otomatik açma işlemini kontrol et ===
      _checkForAutoOpen();
    } catch (e) {
      print('Error loading diary entries: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load diaries. Please check your connection.';
      });
    }
  }

  // === YENİ POP-UP FONKSİYONU: Birden fazla günlük varsa seçim ekranı açar ===
  void _showDiarySelectionPopup(
    BuildContext context,
    List<Map<String, dynamic>> entries,
  ) {
    // entries listesinin boş olmadığını varsayıyoruz.
    final date = entries.first['formattedDate'] ?? 'Selected Day';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final themeProvider = Provider.of<ThemeProvider>(
          context,
          listen: false,
        );
        return AlertDialog(
          backgroundColor: themeProvider.isDarkMode
              ? const Color(0xFF1E1E1E)
              : Colors.white,
          title: Text(
            'Dairy Choice: $date',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: entries.asMap().entries.map((entryItem) {
                final index = entryItem.key;
                final entry = entryItem.value;

                // Başlık veya içerik önizlemesi oluştur
                final contentPreview = entry['content'].toString().isNotEmpty
                    ? '${entry['content'].toString().substring(0, entry['content'].toString().length > 50 ? 50 : entry['content'].toString().length)}...'
                    : 'İçerik yok';

                final entryTitle =
                    entry['title'] ??
                    'Giriş #${index + 1}'; // Eğer title yoksa numara kullan

                return Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.note_alt_outlined,
                        color: themeProvider.isDarkMode
                            ? Colors.blueGrey.shade300
                            : Colors.blueGrey.shade700,
                      ),
                      title: Text(
                        entryTitle,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: themeProvider.isDarkMode
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      subtitle: Text(
                        contentPreview,
                        style: TextStyle(
                          color: themeProvider.isDarkMode
                              ? Colors.grey[400]
                              : Colors.grey[600],
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).pop(); // Seçim pop-up'ını kapat
                        _openDiaryDetail(entry); // Seçilen günlüğü aç
                      },
                    ),
                    if (index < entries.length - 1)
                      Divider(
                        color: themeProvider.isDarkMode
                            ? Colors.grey[700]
                            : Colors.grey[300],
                        height: 1,
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Close',
                style: GoogleFonts.poppins(
                  color: themeProvider.isDarkMode
                      ? Colors.redAccent[100]
                      : Colors.redAccent,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // === GÜNCELLENMİŞ _checkForAutoOpen: Tek/Çoklu günlük kontrolü yapar ===
  void _checkForAutoOpen() {
    if (widget.selectedDate == null) {
      return; // Dışarıdan tarih gelmediyse işlem yapma
    }

    final targetDate = widget.selectedDate!;

    // DiaryService'deki formatı tam olarak yeniden oluşturuyoruz.
    // DiaryService'deki format: 'Ddd, dd Mmm yyyy' (Örn: Wed, 25 Nov 2025)
    final weekday = _getWeekday(targetDate.weekday);
    final month = _getMonth(targetDate.month);
    final targetDateString =
        '$weekday, ${targetDate.day} $month ${targetDate.year}';

    // O güne ait tüm günlükleri filtrele
    final dailyEntries = diaryEntries
        .where((entry) => entry['formattedDate'] == targetDateString)
        .toList();

    if (dailyEntries.isEmpty) {
      // 0 kayıt varsa: Hata mesajı göster
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$targetDateString için bir günlük bulunamadı.'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.orange,
          ),
        );
      });
    } else if (dailyEntries.length == 1) {
      // 1 kayıt varsa: Doğrudan o günlüğü aç
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openDiaryDetail(dailyEntries.first);
      });
    } else {
      // Birden fazla (>1) kayıt varsa: Seçim pop-up'ını aç
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showDiarySelectionPopup(context, dailyEntries);
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

        // Show success message with Get Advice button
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Diary saved successfully!'),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Get Advice',
              textColor: Colors.white,
              onPressed: () {
                _getPsychologicalAdvice();
              },
            ),
          ),
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
      setState(() {
        isLoadingAdvice = true;
      });

      // Get analysis using user data from Firebase
      final analysis = await DiaryService.analyzeDiaries(
        characterType: userCharacterType.isNotEmpty
            ? userCharacterType
            : 'Not specified',
        sign: userSign.isNotEmpty ? userSign : 'Not specified',
        birthMap: 'Not specified', // As requested, not using birth map
        diaryCount: diaryEntries.length,
      );

      setState(() {
        isLoadingAdvice = false;
      });

      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: themeProvider.isDarkMode
              ? const Color(0xFF1E1E1E)
              : Colors.white,
          title: Text(
            'Your Psychological Analysis',
            style: TextStyle(
              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (userName != "User")
                  Text(
                    'For: $userName',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                if (userCharacterType.isNotEmpty)
                  Text(
                    'Personality: $userCharacterType',
                    style: TextStyle(
                      fontSize: 12,
                      color: themeProvider.isDarkMode
                          ? Colors.grey[400]
                          : Colors.grey[600],
                    ),
                  ),
                if (userSign.isNotEmpty)
                  Text(
                    'Zodiac: $userSign',
                    style: TextStyle(
                      fontSize: 12,
                      color: themeProvider.isDarkMode
                          ? Colors.grey[400]
                          : Colors.grey[600],
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  analysis['advice'] ?? 'No advice available.',
                  style: TextStyle(
                    color: themeProvider.isDarkMode
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Close',
                style: TextStyle(
                  color: themeProvider.isDarkMode
                      ? Colors.blueAccent[100]
                      : Colors.blueAccent,
                ),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() {
        isLoadingAdvice = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error getting analysis: $e')));
    }
  }

  Future<void> _getAdviceForDiary(Map<String, dynamic> diaryEntry) async {
    try {
      // Show loading for specific diary
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Creating an advice for ${diaryEntry['formattedDate']}...',
          ),
        ),
      );

      // You might want to modify this to analyze a specific diary
      final analysis = await DiaryService.analyzeDiaries(
        characterType: userCharacterType.isNotEmpty
            ? userCharacterType
            : 'Not specified',
        sign: userSign.isNotEmpty ? userSign : 'Not specified',
        birthMap: 'Not specified',
        diaryCount: 1, // Analyzing based on recent diaries
      );

      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: themeProvider.isDarkMode
              ? const Color(0xFF1E1E1E)
              : Colors.white,
          title: Text(
            'Advice for ${diaryEntry['formattedDate']}',
            style: TextStyle(
              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  analysis['advice'] ?? 'No advice available.',
                  style: TextStyle(
                    color: themeProvider.isDarkMode
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Close',
                style: TextStyle(
                  color: themeProvider.isDarkMode
                      ? Colors.blueAccent[100]
                      : Colors.blueAccent,
                ),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error getting advice: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode
          ? const Color(0xFF121212) // Dark mode background
          : const Color(0xFFE8F4F9), // Light mode background
      body: Stack(
        children: [
          // Katman 1: Ana İçerik
          Column(
            children: [
              // 1. SABİT ÜST KISIM (Top Bar) - SafeArea ile değiştirildi
              SafeArea(
                bottom: false,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Mentra Yazısı - Normal Container
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Text(
                          "Mentra",
                          style: GoogleFonts.pacifico(
                            fontSize: 28,
                            color: themeProvider.isDarkMode
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),
                      ),

                      // Psychology Butonu - Blur efekti ile
                    ],
                  ),
                ),
              ),

              // ✍️ Write Diary Button
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: themeProvider.isDarkMode
                      ? Colors
                            .deepPurple
                            .shade600 // Dark mode button
                      : Colors.black87, // Light mode button
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
                        color: themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.refresh,
                        color: themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.black87,
                      ),
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
                    style: TextStyle(color: Colors.red.shade300, fontSize: 14),
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
                      ? Center(
                          child: CircularProgressIndicator(
                            color: themeProvider.isDarkMode
                                ? Colors.white
                                : Colors.black87,
                          ),
                        )
                      : diaryEntries.isEmpty
                      ? Column(
                          children: [
                            const SizedBox(height: 50),
                            Icon(
                              Icons.edit_note,
                              size: 64,
                              color: themeProvider.isDarkMode
                                  ? Colors.grey.shade600
                                  : Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No diary entries yet.\nStart writing your first diary!",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: themeProvider.isDarkMode
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
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
                                color: themeProvider.isDarkMode
                                    ? const Color(0xFF1E1E1E) // Dark mode card
                                    : Colors.white, // Light mode card
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: themeProvider.isDarkMode
                                        ? Colors.black.withOpacity(0.5)
                                        : Colors.black12,
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
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            entry['formattedDate'] ?? 'No date',
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              color: themeProvider.isDarkMode
                                                  ? Colors.white
                                                  : Colors.black87,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            entry['title'] ??
                                                _titleFromContent(
                                                  entry['content'] ?? '',
                                                ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              color: themeProvider.isDarkMode
                                                  ? Colors.white70
                                                  : Colors.black87,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Get Advice Button
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: themeProvider.isDarkMode
                                            ? Colors
                                                  .deepPurple
                                                  .shade600 // Dark mode
                                            : Colors
                                                  .purple
                                                  .shade500, // Light mode
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: InkWell(
                                        onTap: () => _getAdviceForDiary(entry),
                                        child: const Row(
                                          children: [
                                            Icon(
                                              Icons.psychology,
                                              size: 12,
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              'Get Advice',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // mood etiketi kaldırıldı
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                ),
              ),

              // Alt boşluk - Bottom Navigation için yer açıyoruz
              const SizedBox(height: 80),
            ],
          ),

          // =========================================================
          // 3. SABİT ALT KISIM (FAB NAVİGASYON BUTONLARI - 4 TANE)
          // =========================================================
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: themeProvider.isDarkMode
                          ? Colors.black.withOpacity(0.3)
                          : Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: themeProvider.isDarkMode
                            ? Colors.white.withOpacity(0.2)
                            : Colors.white.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // 1. Home Button
                        IconButton(
                          icon: Icon(
                            Icons.home,
                            color: themeProvider.isDarkMode
                                ? Colors.white
                                : Colors.black87,
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

                        // 2. Advice Button
                        IconButton(
                          icon: Icon(
                            Icons.lightbulb_outline,
                            color: themeProvider.isDarkMode
                                ? Colors.white
                                : Colors.black87,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AdvicePage(),
                              ),
                            );
                          },
                        ),

                        // 3. Mood Track Button
                        IconButton(
                          icon: Icon(
                            Icons.emoji_emotions_outlined,
                            color: themeProvider.isDarkMode
                                ? Colors.white
                                : Colors.black87,
                          ),
                          onPressed: () {
                            // Mood Track Sayfasına yönlendirme
                          },
                        ),

                        // 4. Profile Button
                        IconButton(
                          icon: Icon(
                            Icons.person_outline,
                            color: themeProvider.isDarkMode
                                ? Colors.white
                                : Colors.black87,
                          ),
                          onPressed: () {
                            Navigator.push(
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
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // === YENİ EK: Birden fazla günlük varsa seçim pop-up'ını açan metot ===

  String _getWeekday(int weekday) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[weekday - 1];
  }

  String _getMonth(int month) {
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

  // mood rengi kaldırıldı
}
