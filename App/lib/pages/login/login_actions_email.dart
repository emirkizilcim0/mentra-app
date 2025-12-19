// lib/pages/login/login_actions_email.dart
import 'package:flutter/material.dart';
import 'package:mentra_app/services/auth/auth_service.dart' as app_auth;

class EmailLoginAction {
  static Future<void> execute(
    BuildContext context,
    String email,
    String pass,
    Function(bool) setLoading,
  ) async {
    setLoading(true);

    // app_auth.AuthService diyerek doğru dosyayı zorluyoruz
    final user = await app_auth.AuthService().loginWithEmail(email, pass);

    setLoading(false);

    if (!context.mounted) return;

    if (user != null) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login failed. Check credentials.")),
      );
    }
  }
}
