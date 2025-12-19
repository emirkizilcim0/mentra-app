import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mentra_app/pages/home/home_page.dart';
import 'package:mentra_app/pages/login/login_page.dart';

class SplashLogic {
  static void navigateBasedOnAuth(BuildContext context) {
    if (!context.mounted) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Kullanıcı zaten giriş yapmışsa -> Ana Sayfa
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      // Giriş yapmamışsa -> Login Sayfası
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }
}
