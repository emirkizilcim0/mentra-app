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
      // ESKİ: Navigator.pushReplacementNamed(context, '/home');

      // YENİ: Tüm geçmişi siler ve Home'u ana sayfa yapar
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        (route) =>
            false, // Bu fonksiyon false döndüğü sürece arkadaki her şeyi siler
      );
    }
  }
}
