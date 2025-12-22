import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mentra_app/services/auth/auth_service.dart';
import 'package:mentra_app/pages/profile/profile_helpers.dart';

// ZodiacCalculator importuna artık gerek kalmadı çünkü AuthService hallediyor
// ama kodunda hata vermesin diye durabilir veya silebilirsin.

class SignupSubmissionLogic {
  static Future<bool> signUpAndSaveData(
    String email,
    String pass,
    String first,
    String last,
    DateTime bd,
  ) async {
    try {
      // DÜZELTME BURADA:
      // AuthService artık (email, password, name, birthDate) istiyor.
      // First ve Last name'i birleştirip gönderiyoruz.
      final user = await AuthService().signUpWithEmail(
        email,
        pass,
        "$first $last", // İsim birleştirme
        bd, // Doğum tarihi
      );

      if (user == null) return false;

      // AuthService zaten burcu hesaplayıp kaydettiği için
      // burada tekrar hesaplamaya veya "Unknown" yazmaya gerek yok.
      // O yüzden getZodiac fonksiyonunu sildim/yorum satırı yaptım.

      // Ekstra bilgileri (MBTI, First/Last Name gibi) kaydetmek için update yapıyoruz.
      // SetOptions(merge: true) kullandık ki AuthService'in yazdığı 'sign' (burç) silinmesin.
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {
          'firstName': first,
          'lastName': last,
          'birthDate': bd.toIso8601String(),
          // 'zodiac': "Unknown", // BUNU SİLDİK (AuthService doğrusunu kaydetti, üzerine yazmayalım)
          'email': email,
          // 'createdAt': FieldValue.serverTimestamp(), // AuthService zaten ekliyor, gerek yok
          'mbtiTitle': "No result yet",
          'mbtiDesc': "",
        },
        SetOptions(merge: true),
      ); // ÖNEMLİ: Merge true demezsek önceki veriyi siler

      return true;
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }

  static Future<bool> saveGoogleDetails(
    String first,
    String last,
    DateTime bd,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      final zodiac = getZodiac(bd);

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {
          'firstName': first,
          'lastName': last,
          'birthDate': bd.toIso8601String(),
          'email': user.email ?? '',
          'sign': zodiac,
          'zodiac': zodiac,
          'createdAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      return true;
    } catch (e) {
      print("Error (Google details save): $e");
      return false;
    }
  }
}
