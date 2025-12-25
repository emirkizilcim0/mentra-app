// lib/pages/home/home_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mentra_app/services/dairy/dairy_service.dart';
import 'package:provider/provider.dart';
import 'dart:math';
// HomePage.dart en üste ekle:
import 'package:mentra_app/pages/advice/details/advice_details_page.dart'; // Yolunu kontrol et
import 'package:mentra_app/pages/chat/logic_data.dart'; // Veri çekmek için
import 'package:mentra_app/providers/theme_provider.dart';
import 'package:mentra_app/motivational_speeches.dart';
import 'dialog_ui.dart';
import 'home_date_data.dart';
import 'home_days_generator.dart';
import 'home_view.dart';
import 'home_logic_loader.dart';
import 'loading_view.dart';
import 'package:mentra_app/my_app.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, String> _days = {};
  Map<String, int> _percents = {};

  String _singleQuote = "";
  bool _isLoading = true;
  DateTime _current = DateTime.now();
  final DateTime _today = DateTime.now();

  int _slideDirection = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
    _pickRandomQuote();
  }

  void _pickRandomQuote() {
    if (speeches.isNotEmpty) {
      var now = DateTime.now();
      int dailySeed = (now.year * 10000) + (now.month * 100) + now.day;

      final random = Random(dailySeed);
      String bigBlock = speeches[random.nextInt(speeches.length)];
      List<String> lines = bigBlock.split('\n');

      List<String> cleanQuotes = lines.where((line) {
        String trimmed = line.trim();
        return trimmed.startsWith('“') || trimmed.startsWith('"');
      }).toList();

      if (mounted) {
        setState(() {
          if (cleanQuotes.isNotEmpty) {
            _singleQuote = cleanQuotes[random.nextInt(cleanQuotes.length)];
          } else {
            _singleQuote = bigBlock;
          }
        });
      }
    }
  }

  void _loadData() async {
    try {
      final data = await HomeLogicLoader.load();
      if (mounted) {
        setState(() {
          _days = data['days'];
          _percents = data['percents'];
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _prevMonth() {
    final m = _current.month;
    final y = _current.year;
    setState(() {
      _current = DateTime(m == 1 ? y - 1 : y, m == 1 ? 12 : m - 1, 1);
      _slideDirection = -1;
    });
  }

  void _nextMonth() {
    final m = _current.month;
    final y = _current.year;
    final next = DateTime(m == 12 ? y + 1 : y, m == 12 ? 1 : m + 1, 1);

    // DEĞİŞİKLİK: isFuture kontrolünde _today kullanarak daha sağlam yaptık
    if (next.year > _today.year ||
        (next.year == _today.year && next.month > _today.month)) {
      _showSnackBar('Gelecek aya geçilemez.');
      return;
    }
    setState(() {
      _current = next;
      _slideDirection = 1;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openYearPicker() async {
    final startYear = DateTime.now().year;
    final years = List<int>.generate(12, (i) => startYear - i);
    final selected = await showModalBottomSheet<int>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: ListView.builder(
            itemCount: years.length,
            itemBuilder: (context, index) {
              final y = years[index];
              return ListTile(
                title: Text(y.toString()),
                onTap: () => Navigator.pop<int>(context, y),
              );
            },
          ),
        );
      },
    );
    if (selected != null && mounted) {
      var m = _current.month;
      final now = DateTime.now();
      if (selected == now.year && m > now.month) {
        m = now.month;
      }
      setState(() {
        _current = DateTime(selected, m, 1);
        _slideDirection = 0;
      });
    }
  }

  void _showDetails(int d, int m, int y) {
    // 1. Tarih formatlama
    String year = y.toString();
    String month = (m + 1).toString().padLeft(2, '0');
    String day = d.toString().padLeft(2, '0');
    String searchKey = "$year-$month-$day";

    // 2. Günlük var mı kontrolü
    bool entryExists = false;
    for (String key in _days.keys) {
      if (key.trim().contains(searchKey)) {
        entryExists = true;
        break;
      }
    }

    showDialog(
      context: context,
      builder: (_) => DayDetailsDialog(
        date: DateTime(y, m + 1, d),
        hasEntry: entryExists,
        // YENİ: Advice butonuna tıklanınca çalışacak mantık
        onAdviceTap: () => _openAdviceDirectly(searchKey),
      ),
    );
  }

  // --- YENİ FONKSİYON: DİREKT DETAY SAYFASINI AÇAN MANTIK ---
  // --- GÜNCELLENMİŞ VERSİYON ---
  Future<void> _openAdviceDirectly(String searchKey) async {
    // 1. Loading aç
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // A. Kullanıcı verilerini çek
      final userData = await LogicData.loadUserData();
      String userType = userData['type'] ?? "Not specified";
      String userSign = userData['sign'] ?? "Not specified";

      // B. Günlükleri yükle ve o güne ait olanları bul
      final allDiaries = await LogicData.loadDiaries();
      List<Map<String, dynamic>> dailyEntries = allDiaries
          .where((e) => e['date'].toString().contains(searchKey))
          .toList();

      if (dailyEntries.isEmpty) {
        if (mounted) {
          Navigator.pop(context); // Loading kapat
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Bu tarih için günlük bulunamadı.")),
          );
        }
        return;
      }

      // --- C. FİLTRELEME: Sadece tavsiyesi olanları bul ---
      List<Map<String, dynamic>> diariesWithAdvice = [];

      for (var entry in dailyEntries) {
        // 1. Yerel Kontrol (Telefonda kayıtlı mı?)
        bool hasLocal =
            (entry['advice'] != null &&
                entry['advice'].toString().isNotEmpty) ||
            (entry['analysis'] != null &&
                entry['analysis'].toString().isNotEmpty);

        if (hasLocal) {
          diariesWithAdvice.add(entry);
          continue; // Sıradaki günlüğe geç
        }

        // 2. Firebase Kontrolü (Veritabanında var mı?)
        String diaryId =
            entry['_id']?.toString() ?? entry['id']?.toString() ?? "";
        if (diaryId.isNotEmpty) {
          try {
            var querySnapshot = await FirebaseFirestore.instance
                .collection('analyses')
                .where('diary_id', isEqualTo: diaryId)
                .limit(1)
                .get();

            if (querySnapshot.docs.isNotEmpty) {
              // Firebase'de bulunduysa listeye ekle
              diariesWithAdvice.add(entry);
            }
          } catch (e) {
            print("Firebase kontrol hatası: $e");
          }
        }
      }

      Navigator.pop(context); // Loading'i kapat

      // --- D. SONUÇLARI GÖSTER ---

      if (diariesWithAdvice.isEmpty) {
        // 1. DURUM: Hiçbirinin tavsiyesi yok
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Bu tarihteki günlükler için henüz tavsiye alınmamış.",
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else if (diariesWithAdvice.length == 1) {
        // 2. DURUM: Sadece 1 tanesinin tavsiyesi var -> Direkt Aç
        _processAdviceForEntry(diariesWithAdvice.first, userType, userSign);
      } else {
        // 3. DURUM: Birden fazla tavsiyeli günlük var -> Sadece bunları listele
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("${diariesWithAdvice.length} Advice Found"),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: diariesWithAdvice.length,
                  itemBuilder: (context, index) {
                    final entry = diariesWithAdvice[index];

                    // İçerik özeti
                    String text =
                        entry['content'] ?? entry['text'] ?? "No context";
                    if (text.length > 50) text = "${text.substring(0, 50)}...";

                    return Column(
                      children: [
                        ListTile(
                          leading: const Icon(
                            Icons.auto_awesome,
                            color: Colors.deepPurple,
                          ), // İkonu değiştirdim
                          title: Text(
                            text,
                            style: const TextStyle(fontSize: 14),
                          ),
                          subtitle: const Text(
                            "See advice",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                          ),
                          onTap: () {
                            Navigator.pop(context); // Popup'ı kapat
                            _processAdviceForEntry(entry, userType, userSign);
                          },
                        ),
                        const Divider(height: 1),
                      ],
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Hata: $e")));
      }
    }
  }

  // Tek bir günlüğü alıp Firebase kontrolü yapan yardımcı fonksiyon
  Future<void> _processAdviceForEntry(
    Map<String, dynamic> entry,
    String userType,
    String userSign,
  ) async {
    // Tekrar kısa bir loading gösterelim (Firebase sorgusu için)
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(child: CircularProgressIndicator()),
    );

    try {
      Map<String, dynamic>? foundAnalysis;
      Map<String, dynamic> targetDiary = entry;

      // 1. Önce Yerel Kontrol (Zaten yüklüyse)
      bool hasLocal =
          (entry['advice'] != null && entry['advice'].toString().isNotEmpty) ||
          (entry['analysis'] != null &&
              entry['analysis'].toString().isNotEmpty);

      if (hasLocal) {
        // Yerelde veri var, direkt kullan
        // (Ekstra bir şey yapmaya gerek yok, targetDiary zaten dolu)
      } else {
        // 2. Yerelde yoksa Firebase Kontrolü
        String diaryId =
            entry['_id']?.toString() ?? entry['id']?.toString() ?? "";
        if (diaryId.isNotEmpty) {
          var querySnapshot = await FirebaseFirestore.instance
              .collection('analyses')
              .where('diary_id', isEqualTo: diaryId)
              .limit(1)
              .get();

          if (querySnapshot.docs.isNotEmpty) {
            foundAnalysis = querySnapshot.docs.first.data();
          }
        }
      }

      Navigator.pop(context); // Loading kapat

      // SONUÇ: Tavsiye bulundu mu?
      if (hasLocal || foundAnalysis != null) {
        // VARSA -> Sayfayı Aç
        Map<String, dynamic> finalData = Map.of(targetDiary);
        if (foundAnalysis != null) {
          finalData.addAll(foundAnalysis);
        }

        finalData['character_type'] = userType;
        finalData['sign'] = userSign;
        if (finalData['formattedDate'] == null) {
          finalData['formattedDate'] = targetDiary['date'];
        }

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdviceDetailPage(
                analysisItem: finalData,
                title: "Daily Advice",
              ),
            ),
          );
        }
      } else {
        // YOKSA -> Uyarı Ver
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("There is no advice ."),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      print("Hata: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    // Takvim çizimi için seçili ay verisi (_current)
    final dd = HomeDateData(_current, speeches.length);

    // --- GELECEK AY KONTROLÜ MANTIĞI BURAYA EKLENDİ ---
    final DateTime nextMonthDate = DateTime(
      _current.month == 12 ? _current.year + 1 : _current.year,
      _current.month == 12 ? 1 : _current.month + 1,
      1,
    );

    // Eğer bir sonraki ay, bugünün ayından büyükse butonu gizlemek için false döner
    final bool canGoNext =
        !(nextMonthDate.year > _today.year ||
            (nextMonthDate.year == _today.year &&
                nextMonthDate.month > _today.month));
    // ------------------------------------------------

    return Stack(
      children: [
        HomeView(
          isDark: isDark,
          dd: dd,
          randomSpeech: _singleQuote,
          // HATA BURADAYDI: Yeni parametreyi buraya ekledik
          showNextButton: canGoNext,

          dayWidgets: HomeDaysGenerator.generate(
            dd: dd,
            percents: _percents,
            days: _days,
            isDark: isDark,
            onDayTap: _showDetails,
          ),
          onPrevMonth: _prevMonth,
          onNextMonth: _nextMonth,
          onYearTap: _openYearPicker,
          slideDirection: _slideDirection,
        ),

        if (_isLoading) Positioned.fill(child: LoadingView(isDark: isDark)),
      ],
    );
  }
}
