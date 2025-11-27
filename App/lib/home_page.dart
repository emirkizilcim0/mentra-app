import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'routes_manager.dart';
import 'chat_page.dart';
import 'profile_page.dart';
import 'motivational_speeches.dart';
import 'services/diary_service.dart';

// Varsayılan AdvicePage tanımı
class AdvicePage extends StatelessWidget {
  const AdvicePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tavsiye Sayfası')),
      body: const Center(child: Text('Burada Günlük Tavsiyeler Yer Alacak.')),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // === 1. Günlüğü Olan Günlerin Durumunu Tutmak İçin Map  ===
  // Key: YYYY-MM-DD. Value: 'written', 'advised', veya 'none'
  Map<String, String> _daysWithDiaryStatus = {};

  @override
  void initState() {
    super.initState();
    _loadDiaryAvailabilityStatus();
  }

  // === 2. Tüm günlükleri ve Advice durumlarını çek (GÜNCELLENDİ) ===
  Future<void> _loadDiaryAvailabilityStatus() async {
    try {
      final entries = await DiaryService.getDiaryEntries();
      // Advice geçmişini çekiyoruz (Service'te var olduğunu varsayıyoruz)
      final analyses = await DiaryService.getAnalysisHistory();

      final Map<String, String> days = {};

      // Advice alınan günleri topluyoruz (YYYY-MM-DD formatında)
      Set<String> advisedDays = {};
      for (var analysis in analyses) {
        try {
          final analysisDate = DateTime.parse(analysis['date']);
          final key = DateFormat('yyyy-MM-dd').format(analysisDate);
          advisedDays.add(key);
        } catch (_) {
          // Hata durumunda yoksay
        }
      }

      for (var entry in entries) {
        final dateString = entry['date'] as String;
        final date = DateTime.parse(dateString);
        final key = DateFormat('yyyy-MM-dd').format(date);

        // Önce Advice kontrolü yapılır: Advice varsa Koyu Mor, yoksa Açık Mor
        if (advisedDays.contains(key)) {
          days[key] = 'advised'; // Koyu Mor
        } else {
          days[key] = 'written'; // Açık Mor
        }
      }

      setState(() {
        _daysWithDiaryStatus = days;
      });

      print('DEBUG: ${days.length} diary statuses loaded.');
    } catch (e) {
      print(
        'CRITICAL ERROR! Exception occurred while loading diary status: $e',
      );
    }
  }

  // ===  Günlük durumunu kontrol et ) ===
  String _getDiaryStatus(int day, int monthIndex, int year) {
    final date = DateTime(year, monthIndex + 1, day);
    final key = DateFormat('yyyy-MM-dd').format(date);
    return _daysWithDiaryStatus[key] ?? 'none';
  }

  Future<void> _handleDiarySelection(
    BuildContext context,
    DateTime selectedDate,
  ) async {
    final weekday = _getWeekday(selectedDate.weekday);
    final month = _getMonth(selectedDate.month);
    final targetDateString =
        '$weekday, ${selectedDate.day} $month ${selectedDate.year}';

    final snackBar = SnackBar(
      content: Text('Searching for diary entry for $targetDateString...'),
      duration: const Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    try {
      final entries = await DiaryService.getDiaryEntries();
      final dailyEntries = entries
          .where((entry) => entry['formattedDate'] == targetDateString)
          .toList();

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (dailyEntries.isNotEmpty) {
        print('DEBUG: Diary found, redirecting to ChatPage.');
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(selectedDate: selectedDate),
          ),
        );
        _loadDiaryAvailabilityStatus(); // Geri dönüşte durumu güncelle
      } else {
        print(
          'WARNING: Diary entry not found, but the page is still opening (Error Management).',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Diary entry not found, but the page is opening.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(selectedDate: selectedDate),
          ),
        );
        _loadDiaryAvailabilityStatus();
      }
    } catch (e) {
      print('CRITICAL ERROR! Exception occurred while loading diary $e');
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'A critical error occurred while loading the diary. Details in the console.',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(selectedDate: selectedDate),
        ),
      );
      _loadDiaryAvailabilityStatus();
    }
  }
  // =========================================================

  // Pop-up
  void _showDayDetailsPopup(
    BuildContext context,
    int day,
    int monthIndex,
    int year,
  ) {
    final selectedDate = DateTime(year, monthIndex + 1, day);
    final monthName = DateFormat.MMMM('en_US').format(selectedDate);
    final bool hasDiaryEntry = _getDiaryStatus(day, monthIndex, year) != 'none';

    if (!hasDiaryEntry) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            ' ${day} ${monthName.toUpperCase()}',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.book_outlined,
                    color: Color.fromARGB(255, 41, 68, 81),
                  ),
                  title: Text(
                    'Daily Diary',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: hasDiaryEntry
                      ? () {
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ChatPage(selectedDate: selectedDate),
                            ),
                          );
                        }
                      : null,
                ),

                const Divider(),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.lightbulb_outline,
                    color: Color(0xFFB3E5FC),
                  ),
                  title: Text(
                    'Advice',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdvicePage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Close',
                style: GoogleFonts.poppins(
                  color: const Color.fromARGB(255, 169, 35, 35),
                  fontWeight: FontWeight.bold,
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

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final month = DateFormat.MMMM().format(now);
    final monthIndex = now.month - 1; // Ayın indexi (0-11)
    final year = now.year;
    final dayOfYear = int.parse(DateFormat("D").format(now));
    final speechIndex = dayOfYear % speeches.length;
    final todaySpeech = speeches[speechIndex];

    final lastDayOfMonth = DateTime(year, now.month + 1, 0).day;

    final firstDayOfMonth = DateTime(year, now.month, 1);

    int dayOfWeek = firstDayOfMonth.weekday;

    final blankSpaces = dayOfWeek % 7;

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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const ChatPage(selectedDate: null),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.black87,
                      size: 26,
                    ),
                  ),
                ],
              ),
            ),

            // 🗓 Calendar Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black12, width: 1.5),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "$month",
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        "$year",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Days of week (SUN, MON, TUE...)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
                        .map(
                          (d) => Text(
                            d,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 10),

                  // Calendar grid (GÜNCELLENDİ)
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    // Toplam ızgara elemanı: Boşluklar + Günler
                    children: List.generate(blankSpaces + lastDayOfMonth, (
                      index,
                    ) {
                      // Eğer index boşluk sayısından küçükse, bu bir boş kutudur.
                      if (index < blankSpaces) {
                        return const SizedBox(
                          width: 38, // Gün kutusu ile aynı genişlik
                          height: 38,
                        );
                      }

                      // Gerçek gün numarasını hesapla
                      final day = index + 1 - blankSpaces;
                      final isToday =
                          day == now.day &&
                          year == now.year &&
                          (now.month == monthIndex + 1);

                      final String diaryStatus = _getDiaryStatus(
                        day,
                        monthIndex,
                        year,
                      );
                      final bool hasDiaryForDay = diaryStatus != 'none';

                      return GestureDetector(
                        onTap: hasDiaryForDay
                            ? () {
                                _showDayDetailsPopup(
                                  context,
                                  day,
                                  monthIndex,
                                  year,
                                );
                              }
                            : null,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: isToday
                                ? const Color(0xFFB3E5FC)
                                : (diaryStatus == 'advised')
                                ? Colors
                                      .deepPurple
                                      .shade400 // Advice Varsa: Koyu Mor
                                : (diaryStatus == 'written')
                                ? Colors
                                      .purple
                                      .shade200 // Sadece Yazılıysa: Açık Mor
                                : Colors.white, // Günlük yoksa: Beyaz
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.black26),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "$day",
                            style: GoogleFonts.poppins(
                              fontWeight: isToday
                                  ? FontWeight.bold
                                  : FontWeight.w400,

                              color: (diaryStatus == 'advised')
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            // 📝 Speech Card - Updated to handle long text
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFF7F7), Color(0xFFFDEDED)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header section
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.auto_fix_high,
                              color: Colors.black87,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Daily Motivation",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                color: Colors.black87,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              "$month ${now.day}, $year",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Speech content - takes remaining space
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Text(
                              todaySpeech,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                height: 1.7,
                                color: Colors.black87,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                      ),

                      // Bottom padding
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),

            // ⚙ Bottom Navigation Bar
            Container(
              height: 65,
              decoration: const BoxDecoration(
                color: Color(0xFFD0E8EF),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.home, size: 28, color: Colors.black),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.person_outline,
                      size: 28,
                      color: Colors.black,
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
          ],
        ),
      ),
    );
  }

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
}
