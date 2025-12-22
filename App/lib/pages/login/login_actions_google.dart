// lib/pages/login/login_actions_google.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mentra_app/services/auth/auth_service.dart' as app_auth;
// Çakışmayı önlemek için 'as' etiketi kullanıyoruz
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mentra_app/pages/signupDetails/signup_details_page.dart';

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
        final uid = user.uid;
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();
        final data = doc.data();
        final hasProfile =
            data != null &&
            ((data['firstName'] ?? '').toString().isNotEmpty) &&
            ((data['lastName'] ?? '').toString().isNotEmpty) &&
            ((data['birthDate'] ?? '').toString().isNotEmpty);

        if (hasProfile) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const SignupDetailsPage(
                email: '',
                password: '',
                isGoogle: true,
              ),
            ),
          );
        }
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
