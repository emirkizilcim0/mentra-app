import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mentra_app/pages/profile/profile_helpers.dart';
import 'package:mentra_app/services/auth/auth_email.dart';
import 'package:mentra_app/services/auth/auth_google.dart';

// DİKKAT: zodiac_calculator.dart dosyan hangi klasördeyse yolunu ona göre düzenle
import 'package:mentra_app/pages/signupDetails/zodiac_calculator.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Google Girişi
  Future<User?> signInWithGoogle() {
    return AuthGoogle.signIn(_auth);
  }

  // --- E-posta Kayıt (GÜNCELLENDİ) ---
  // Parametrelere 'name' ve 'birthDate' eklendi
  Future<User?> signUpWithEmail(
    String email,
    String password,
    String name,
    DateTime birthDate,
  ) async {
    // 1. Auth işlemini yap (Kullanıcıyı oluştur)
    User? user = await AuthEmail.signUp(_auth, email, password);

    // 2. Kullanıcı oluştuysa, Firestore'a detayları kaydet
    if (user != null) {
      try {
        // Var olan dosyandan fonksiyonu çağırıyoruz
        // (Fonksiyon isminin calculateZodiacSign olduğunu varsayıyorum)
        String zodiacSign = getZodiac(birthDate);

        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
          'birthDate': birthDate.toIso8601String(),
          'sign': zodiacSign, // Burcu otomatik ekledik
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        print("Firestore kayıt hatası: $e");
      }
    }

    return user;
  }

  // E-posta Giriş
  Future<User?> loginWithEmail(String email, String password) {
    return AuthEmail.login(_auth, email, password);
  }

  // Çıkış
  Future<void> signOut() async {
    await _auth.signOut();
    await AuthGoogle.signOut();
  }
}
