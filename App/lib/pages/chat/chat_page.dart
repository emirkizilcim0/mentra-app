import 'package:flutter/material.dart';
import 'package:mentra_app/pages/dairy/write/dairy_write_page.dart';
import 'package:mentra_app/providers/theme_provider.dart';
import 'package:mentra_app/services/dairy/dairy_service.dart';
import 'package:provider/provider.dart';
// Detay sayfasını import et
import 'package:mentra_app/pages/advice/details/advice_details_page.dart';
import 'advice_utils.dart';
import 'package:intl/intl.dart';
import '../home/loading_view.dart';
import 'logic_data.dart';
import 'logic_nav.dart';
import 'advice_page.dart';
import 'chat_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  // --- TARİH FORMATLAYICI ---
  String _formatDate(dynamic dateStr) {
    try {
      if (dateStr == null) return "";
      DateTime date;
      if (dateStr is DateTime) {
        date = dateStr;
      } else {
        date = DateTime.parse(dateStr.toString());
      }
      // US Formatı: "November 27, 2025" (Detay sayfasındaki ile uyumlu olsun)
      return DateFormat('d MMMM, yyyy', 'en_US').format(date.toLocal());
    } catch (_) {
      return dateStr.toString();
    }
  }

  Future<void> _loadDiaries() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      // 1. Telefondaki Günlükleri Çek
      final items = await LogicData.loadDiaries();

      // 2. Firebase'den Analizleri Çek
      // 'analyses' tablosu yoksa bile hata vermez, boş döner.
      final QuerySnapshot analysisSnapshot = await FirebaseFirestore.instance
          .collection('analyses')
          .get();

      // Gelen veriyi listeye çevir
      final List<Map<String, dynamic>> analysesList = analysisSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      // 3. Eşleştirme Yap (Günlük ID == Analiz Diary ID)
      for (var item in items) {
        // Tarihi düzelt
        if (item['date'] != null) {
          item['formattedDate'] = _formatDate(item['date']);
        }

        // Günlüğün ID'sini al (String'e çevirerek garantiye alıyoruz)
        String localId =
            item['id']?.toString() ?? item['_id']?.toString() ?? "";

        // Listede bu ID'ye sahip analiz var mı?
        final matchingAnalysis = analysesList.firstWhere(
          (analysis) => analysis['diary_id'].toString() == localId,
          orElse: () => {},
        );

        // Varsa, günlüğe ekle (Böylece buton görünecek!)
        if (matchingAnalysis.isNotEmpty) {
          item['advice'] = matchingAnalysis['advice'];
          item['analysis'] = matchingAnalysis['analysis'];
          item['mood'] = matchingAnalysis['mood'];
        }
      }

      setState(() {
        diaries = items;
        loading = false;
      });

      // (Otomatik açılma kodları buraya gelebilir, aynı kalacak)
      if (mounted && widget.selectedDate != null && widget.showAdvice) {
        // ... eski mantık ...
        String y = widget.selectedDate!.year.toString();
        String m = widget.selectedDate!.month.toString().padLeft(2, '0');
        String d = widget.selectedDate!.day.toString().padLeft(2, '0');
        String targetKey = "$y-$m-$d";
        final foundEntry = items.firstWhere(
          (e) => e['date'].toString().contains(targetKey),
          orElse: () => {},
        );
        if (foundEntry.isNotEmpty)
          _getAdvice(foundEntry);
        else
          _getAdvice(null);
      } else if (mounted) {
        LogicNav.checkForAutoOpen(
          context,
          widget.selectedDate,
          items,
          Provider.of<ThemeProvider>(context, listen: false).isDarkMode,
        );
      }
    } catch (e) {
      print("Yükleme Hatası: $e");
      setState(() {
        loading = false;
        error = 'Failed to load.';
      });
    }
  }

  // --- KRİTİK ADVICE FONKSİYONU ---
  Future<void> _getAdvice(Map<String, dynamic>? entry) async {
    setState(() {
      _isAnalyzing = true;
    });

    print("📢 1. BAŞLANGIÇ: _getAdvice çalıştı.");

    try {
      // Zaten varsa aç
      if (entry != null &&
          entry['advice'] != null &&
          entry['advice'].toString().isNotEmpty) {
        print("📢 2. DURUM: Zaten advice var, direkt açılıyor.");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AdviceDetailPage(analysisItem: entry, title: "Daily Advice"),
          ),
        );
        setState(() {
          _isAnalyzing = false;
        });
        return;
      }

      Map<String, dynamic>? finalData;

      if (finalData == null) {
        String? currentId;
        if (entry != null) {
          currentId = entry['id']?.toString() ?? entry['_id']?.toString();
        }
        print("📢 3. ID TESPİTİ: İşlem yapılacak ID: $currentId");

        // AI Analizi
        print("📢 4. DURUM: AI servisine gidiliyor...");
        final Map<String, dynamic> response = await DiaryService.analyzeDiaries(
          characterType: type,
          sign: sign,
          birthMap: 'Not specified',
          diaryCount: 1, // CRITICAL: Always 1, not 0!
          specificContent: entry != null
              ? (entry['content'] ?? entry['text'] ?? "")
              : null,
          specificIds: currentId != null ? [currentId] : null,
          userDiaries: entry != null ? [entry] : null,
        );
        print("📢 5. DURUM: AI cevabı geldi.");

        finalData = Map.of(response);

        // --- KAYIT KISMI (HATAYI BURADA ARIYORUZ) ---
        if (entry != null && currentId != null) {
          print("📢 6. DURUM: Firebase'e yazma işlemi başlıyor...");

          try {
            await FirebaseFirestore.instance.collection('analyses').add({
              'diary_id': currentId,
              'advice': finalData['advice'],
              'analysis': finalData['analysis'],
              'mood': finalData['mood'],
              'created_at': FieldValue.serverTimestamp(),
            });
            print("✅✅✅ 7. BAŞARI: FIREBASE'E KAYDEDİLDİ! ✅✅✅");
          } catch (firebaseError) {
            print("❌❌❌ FIREBASE HATASI: $firebaseError ❌❌❌");
          }
        } else {
          print("⚠️ UYARI: ID veya Entry null olduğu için kayıt atlandı.");
        }
        // ---------------------------------------------

        _loadDiaries();
      }

      // Sayfayı Aç
      if (finalData != null) {
        // ... (Veri hazırlama kısmı aynı) ...
        if (entry != null) {
          finalData['date'] = entry['date'];
          finalData['formattedDate'] = _formatDate(entry['date']);
        }
        finalData['character_type'] = type;
        finalData['sign'] = sign;
        if (finalData['mood'] == null) finalData['mood'] = 'Calm';

        if (mounted) {
          setState(() {
            _isAnalyzing = false;
          });
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdviceDetailPage(
                analysisItem: finalData!,
                title: "Analysis Result",
              ),
            ),
          );
        }
      }
    } catch (e) {
      print("❌❌❌ GENEL HATA: $e ❌❌❌");
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  // ChatPage.dart içindeki _write fonksiyonu
  Future<void> _write() async {
    // 1. Yazma sayfasına git
    final res = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DiaryWritePage()),
    );

    if (res != null) {
      // 2. Veritabanına kaydet
      await DiaryService.saveDiaryEntry(res);

      // 3. LİSTEYİ YENİLE (Burası çalışınca buton otomatik listede çıkacak)
      await _loadDiaries();

      // 4. Sadece "Kaydedildi" yazısı göster (Buton yok)
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
          // ChatViewBody'ye fonksiyonları gönderiyoruz
          body: ChatViewBody(
            isDark: isDark,
            isLoading: loading,
            error: error,
            entries: diaries,
            onRefresh: _loadDiaries,
            onWrite: _write,
            onDetail: (e) => LogicNav.openDiaryDetail(context, e),
            onAdvice: _getAdvice, // DiaryCard içindeki buton burayı tetikler
          ),
        ),
        if (_isAnalyzing) Positioned.fill(child: LoadingView(isDark: isDark)),
      ],
    );
  }
}
