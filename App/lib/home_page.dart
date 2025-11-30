import 'dart:async';
import 'dart:ui'; // BackdropFilter için gereklidir
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'routes_manager.dart';
import 'chat_page.dart';
import 'profile_page.dart';
import 'motivational_speeches.dart';
import 'services/diary_service.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';

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

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  // === 1. Günlüğü Olan Günlerin Durumunu Tutmak İçin Map  ===
  Map<String, String> _daysWithDiaryStatus = {};

  bool _isLoading = true;

  // 💡 YENİ ANİMASYON DEĞİŞKENLERİ
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  late Animation<double> _floatAnimation;
  int _dotCount = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // 1. AnimationController'ı başlat
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // Bir saniyede bir döngü
    );
    // 2. Animasyonu opaklık (0.3'ten 1.0'a) olarak tanımla ve tekrar et
    _opacityAnimation = Tween(
      begin: 0.3,
      end: 1.0,
    ).animate(_animationController);
    _floatAnimation = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutSine, // Yumuşak yaylanma eğrisi kullanıyoruz
      ),
    );
    _animationController.repeat(
      reverse: true,
    ); // Sürekli olarak ileri/geri tekrar et
    _startDotAnimation();

    _loadDiaryAvailabilityStatus();
  }

  // 💡 OPTİMİZASYON: Noktaları sırayla gösteren fonksiyon (Manuel sayaç kontrolü)
  void _startDotAnimation() {
    _timer?.cancel();
    _dotCount = 0; // Sayacı sıfırdan başlat

    _timer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (_isLoading) {
        setState(() {
          _dotCount++;
          // Maksimum 3 nokta (4. durum, yani _dotCount=4) oluşursa
          // sayacı tekrar sıfıra (_dotCount=0) ayarla.
          if (_dotCount > 3) {
            _dotCount = 0;
          }
        });
      } else {
        timer.cancel(); // Yükleme bittiyse durdur
        setState(() {
          _dotCount = 3; // Yükleme tamamlanınca 3 nokta kalsın
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose(); // Controller'ı temizle
    _timer?.cancel(); // 💡 OPTİMİZASYON: Timer'ı temizle
    super.dispose();
  }

  // === 2. Tüm günlükleri ve Advice durumlarını çek (DÜZELTİLDİ) ===
  Future<void> _loadDiaryAvailabilityStatus() async {
    // YÜKLEMEYİ BAŞLAT
    setState(() {
      _isLoading = true;
      _animationController.repeat(reverse: true); // Animasyonu başlat
    });

    try {
      final entries = await DiaryService.getDiaryEntries();
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

      // Veriler başarıyla çekildi ve haritalandı
      setState(() {
        _daysWithDiaryStatus = days;
        _isLoading = false;
        _animationController.stop(); // Yükleme bitti, animasyonu durdur
        _timer?.cancel(); // 💡 OPTİMİZASYON: Timer'ı durdur
        _dotCount = 3; // Noktaları sabitle
      });

      print('DEBUG: ${days.length} diary statuses loaded.');
    } catch (e) {
      print(
        'CRITICAL ERROR! Exception occurred while loading diary status: $e',
      );
      // Hata olsa bile yüklemeyi bitir
      setState(() {
        _isLoading = false;
        _animationController.stop(); // Yükleme bitti, animasyonu durdur
        _timer?.cancel(); // 💡 OPTİMİZASYON: Timer'ı durdur
        _dotCount = 3; // Noktaları sabitle
      });
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
      // 💡 OPTİMİZASYON: Günlük sorgusunu hedefli hale getir. Eğer DiaryService
      // tüm girişleri çekmek yerine sadece o güne ait girişi çekebiliyorsa,
      // bu sorgu hızlanacaktır. (Mevcut kodda bu düzeltme yapılamaz, ancak akılda tutulmalıdır)
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

  // --- Floating Action Button Helper Fonksiyonu ---
  Widget _buildFab({
    required IconData icon,
    required VoidCallback onPressed,
    Color color = const Color(0xFFB3E5FC),
    double size = 30,
  }) {
    return FloatingActionButton(
      heroTag: icon.codePoint.toString(), // Her FAB için benzersiz tag gerekli
      shape: const CircleBorder(),
      backgroundColor: color,
      mini: size < 40, // Küçük FAB için mini: true kullanırız
      onPressed: onPressed,
      child: Icon(icon, size: size * 0.9, color: Colors.black87),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
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

    final bottomPadding = 90.0;

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode
          ? const Color(0xFF121212) // Dark mode background
          : const Color(0xFFE8F4F9), // Light mode background

      body: Stack(
        children: [
          // Katman 1: Ana İçerik (Sabit Üst ve Kaydırılabilir Orta Kısım)
          Column(
            children: [
              // 1. SABİT ÜST KISIM (Top Bar)
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Mentra Yazısı (Şeffaf FAB)
                      FloatingActionButton.extended(
                        heroTag: 'mentraTitle',
                        onPressed: () {},
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        label: Text(
                          "Mentra",
                          style: GoogleFonts.pacifico(
                            fontSize: 28,
                            color: themeProvider.isDarkMode
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),
                      ),
                      // Chat FAB (Küçük FAB)
                      FloatingActionButton(
                        heroTag: 'chatButtonTop',
                        mini: true,
                        shape: const CircleBorder(),
                        backgroundColor: themeProvider.isDarkMode
                            ? const Color(0xFF2D2D2D)
                            : Colors.white,
                        elevation: 2.0,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ChatPage(selectedDate: null),
                            ),
                          );
                        },
                        child: Icon(
                          Icons.chat_bubble_outline,
                          color: themeProvider.isDarkMode
                              ? Colors.white
                              : Colors.black87,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. KAYDIRILABİLİR ORTA KISIM
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: bottomPadding),
                  child: Column(
                    children: [
                      // 🗓 Calendar Card
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: themeProvider.isDarkMode
                              ? const Color(0xFF1E1E1E)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: themeProvider.isDarkMode
                                ? Colors.grey.withOpacity(0.3)
                                : Colors.black12,
                            width: 1.5,
                          ),
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
                                    color: themeProvider.isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                Text(
                                  "$year",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: themeProvider.isDarkMode
                                        ? Colors.white70
                                        : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Days of week (SUN, MON, TUE...)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children:
                                  [
                                        "SUN",
                                        "MON",
                                        "TUE",
                                        "WED",
                                        "THU",
                                        "FRI",
                                        "SAT",
                                      ]
                                      .map(
                                        (d) => Text(
                                          d,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                            color: themeProvider.isDarkMode
                                                ? Colors.white70
                                                : Colors.black87,
                                          ),
                                        ),
                                      )
                                      .toList(),
                            ),
                            const SizedBox(height: 10),

                            // Calendar grid
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: List.generate(
                                blankSpaces + lastDayOfMonth,
                                (index) {
                                  if (index < blankSpaces) {
                                    return const SizedBox(
                                      width: 38,
                                      height: 38,
                                    );
                                  }

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
                                  final bool hasDiaryForDay =
                                      diaryStatus != 'none';

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
                                            ? Colors.deepPurple.shade400
                                            : (diaryStatus == 'written')
                                            ? Colors.purple.shade200
                                            : (themeProvider.isDarkMode
                                                  ? const Color(0xFF2D2D2D)
                                                  : Colors.white),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: themeProvider.isDarkMode
                                              ? Colors.grey.withOpacity(0.5)
                                              : Colors.black26,
                                          width: 1,
                                        ),
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
                                              : (themeProvider.isDarkMode
                                                    ? Colors.white
                                                    : Colors.black87),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 📝 Speech Card
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: themeProvider.isDarkMode
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFF2D1B69),
                                      Color(0xFF1A103C),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : const LinearGradient(
                                    colors: [
                                      Color(0xFFFFF7F7),
                                      Color(0xFFFDEDED),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: themeProvider.isDarkMode
                                    ? Colors.black54
                                    : Colors.black12,
                                blurRadius: 8,
                                offset: const Offset(0, 4),
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
                                    Icon(
                                      Icons.auto_fix_high,
                                      color: themeProvider.isDarkMode
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Daily Motivation",
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18,
                                        color: themeProvider.isDarkMode
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      "$month ${now.day}, $year",
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14,
                                        color: themeProvider.isDarkMode
                                            ? Colors.white70
                                            : Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Speech content - takes remaining space
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                child: Text(
                                  todaySpeech,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    height: 1.7,
                                    color: themeProvider.isDarkMode
                                        ? Colors.white
                                        : Colors.black87,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),

                              // Bottom padding
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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

                          onPressed: () {},
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

          // =========================================================
          // 4. LOADING OVERLAY (ANIMASYONLU)
          // =========================================================
          // 💡 Animasyon eklendi: AnimatedOpacity ve FadeTransition
          AnimatedOpacity(
            opacity: _isLoading ? 1.0 : 0.0, // Yükleniyorsa tam, değilse şeffaf
            duration: const Duration(milliseconds: 500),
            child: IgnorePointer(
              ignoring: !_isLoading,
              child: AbsorbPointer(
                absorbing: true,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Container(
                    color: themeProvider.isDarkMode
                        ? Colors.black.withOpacity(0.7)
                        : Colors.white.withOpacity(0.7),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedBuilder(
                            // Floating animasyonunu uygular
                            animation: _floatAnimation,
                            builder: (context, child) {
                              // Y ekseninde _floatAnimation değerinde hareket et
                              return Transform.translate(
                                offset: Offset(0, _floatAnimation.value),
                                child: child,
                              );
                            },
                            // Logo widget'ı
                            child: Image.asset(
                              'assets/logo.png',
                              width: 300,
                              height: 300,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // 💡 FADE TRANSITION İLE YAZIYA SÜREKLİ ANİMASYON
                          FadeTransition(
                            opacity: _opacityAnimation,
                            child: Text(
                              // 💡 DÜZELTİLMİŞ KISIM: Dinamik nokta eklenmesi
                              "Mentra Yükleniyor" +
                                  List.filled(_dotCount, '.').join(),
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: themeProvider.isDarkMode
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
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
