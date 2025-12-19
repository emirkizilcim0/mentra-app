// lib/services/auth/auth_google.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthGoogle {
  // Scopes: E-posta erişimi için gerekli izinler
  static final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  static Future<User?> signIn(FirebaseAuth auth) async {
    try {
      // 1. Google penceresini aç
      // NOT: Burada await kullanmazsan hata alırsın
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) return null; // Kullanıcı pencereyi kapattı

      // 2. Kimlik doğrulama bilgilerini (Token) al
      // NOT: Buradaki 'await' çok önemlidir! Yoksa accessToken gelmez.
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3. Firebase için kimlik kartı (Credential) oluştur
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Firebase'e giriş yap
      final UserCredential userCredential = await auth.signInWithCredential(
        credential,
      );

      return userCredential.user;
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null;
    }
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
