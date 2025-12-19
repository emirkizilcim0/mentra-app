// lib/pages/login/login_actions_google.dart
import 'package:flutter/material.dart';
import 'package:mentra_app/pages/signupDetails/signup_submission_logic.dart';
import 'package:mentra_app/services/auth/auth_service.dart' as app_auth;
// Çakışmayı önlemek için 'as' etiketi kullanıyoruz

class GoogleLoginAction {
  static Future<void> execute(
    BuildContext context,
    Function(bool) setLoading,
  ) async {
    setLoading(true);

    // app_auth.AuthService diyerek doğru dosyayı zorluyoruz
    final user = await app_auth.AuthService().signInWithGoogle();

    setLoading(false);

    if (!context.mounted) return;

    if (user != null) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Google sign-in failed.")));
    }
  }
}
