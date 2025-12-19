// lib/services/auth/auth_email.dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthEmail {
  static Future<User?> signUp(
    FirebaseAuth auth,
    String email,
    String pass,
  ) async {
    try {
      UserCredential res = await auth.createUserWithEmailAndPassword(
        email: email,
        password: pass,
      );
      return res.user;
    } catch (e) {
      print("SignUp Error: $e");
      return null;
    }
  }

  static Future<User?> login(
    FirebaseAuth auth,
    String email,
    String pass,
  ) async {
    try {
      UserCredential res = await auth.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );
      return res.user;
    } catch (e) {
      print("Login Error: $e");
      return null;
    }
  }
}
