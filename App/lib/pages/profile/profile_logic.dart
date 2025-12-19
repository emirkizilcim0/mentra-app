import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
// Burç hesaplama fonksiyonunun olduğu dosyayı import et
import 'package:mentra_app/pages/profile/profile_helpers.dart';

class ProfileLogic {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static Future<Map<String, dynamic>> loadData() async {
    final user = _auth.currentUser;
    if (user == null) return {};

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return {};

      final data = doc.data()!;

      // 1. Verileri Çek
      String name = data['name'] ?? "";
      // Hem 'sign' hem 'zodiac' kontrolü
      String zodiac = data['sign'] ?? data['zodiac'] ?? "";

      // MBTI Verileri
      String mbtiType = data['mbtiResult'] ?? "";
      String mbtiTitle = data['mbtiTitle'] ?? "No result";
      String mbtiDesc = data['mbtiDesc'] ?? "";

      // 2. Tarih İşlemleri ve OTOMATİK DÜZELTME
      String birthDateStr = "";
      DateTime? selectedDate;

      if (data['birthDate'] != null) {
        // Timestamp ise DateTime'a çevir
        if (data['birthDate'] is Timestamp) {
          selectedDate = (data['birthDate'] as Timestamp).toDate();
        }
        // String olarak kaydedilmişse (örn: "2000-01-01") parse et
        else if (data['birthDate'] is String) {
          selectedDate = DateTime.tryParse(data['birthDate']);
        }

        if (selectedDate != null) {
          birthDateStr = DateFormat('d MMMM yyyy').format(selectedDate);

          // --- KRİTİK DÜZELTME BURASI ---
          // Eğer Tarih VAR ama Burç YOKSA (Boşsa), hemen hesapla!
          if (zodiac.isEmpty) {
            zodiac = getZodiac(selectedDate); // Helper'dan çağır

            // İsteğe bağlı: Hazır hesaplamışken veritabanını da güncelle ki bir daha uğraşmasın
            _firestore.collection('users').doc(user.uid).set({
              'sign': zodiac, // veya 'zodiac'
            }, SetOptions(merge: true));
          }
        }
      }

      return {
        'name': name,
        'zodiac': zodiac, // Artık dolu gelecek
        'sign': zodiac,
        'birthDateStr': birthDateStr,
        'selectedDate': selectedDate,
        'mbtiType': mbtiType,
        'mbtiTitle': mbtiTitle,
        'mbtiDesc': mbtiDesc,
      };
    } catch (e) {
      print("Profile Load Error: $e");
      return {};
    }
  }

  static Future<void> updateBirthData(DateTime date, String zodiac) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).set({
      'birthDate': Timestamp.fromDate(
        date,
      ), // Tarihi Timestamp olarak kaydetmek daha güvenlidir
      'sign': zodiac, // Burcu kaydet
      'zodiac': zodiac, // İkisini de kaydet ki garanti olsun
    }, SetOptions(merge: true));
  }
}
