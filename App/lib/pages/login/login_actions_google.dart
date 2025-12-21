// lib/pages/login/login_actions_google.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mentra_app/services/auth/auth_service.dart' as app_auth;
// Çakışmayı önlemek için 'as' etiketi kullanıyoruz

class GoogleLoginAction {
  static Future<void> execute(
    BuildContext context,
    Function(bool) setLoading,
  ) async {
    setLoading(true);
    try {
      final user = await app_auth.AuthService().signInWithGoogle();
      if (!context.mounted) return;
      if (user != null) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google giriş iptal edildi.')),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      final msg = e.code == 'account-exists-with-different-credential'
          ? 'Bu e-posta başka sağlayıcı ile kayıtlı.'
          : e.code == 'network-request-failed'
          ? 'Ağ hatası. Lütfen bağlantınızı kontrol edin.'
          : 'Google girişi başarısız: ${e.code}';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Google girişi başarısız.')));
    } finally {
      setLoading(false);
    }
  }
}
