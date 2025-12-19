import 'package:firebase_auth/firebase_auth.dart';
import 'package:mentra_app/services/auth/auth_email.dart';
import 'package:mentra_app/services/auth/auth_google.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Google Girişi (Bu metod eksik olduğu için hata alıyordun)
  Future<User?> signInWithGoogle() {
    return AuthGoogle.signIn(_auth);
  }

  // E-posta Kayıt
  Future<User?> signUpWithEmail(String email, String password) {
    return AuthEmail.signUp(_auth, email, password);
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
