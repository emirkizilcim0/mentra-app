import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mentra_app/pages/home/home_page.dart';
import 'package:mentra_app/pages/login/login_page.dart';

class SplashLogic {
  static void navigateBasedOnAuth(BuildContext context) {
    if (!context.mounted) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // HomePage'e giderken arkadaki her şeyi (Splash dahil) SİL
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
    } else {
      // LoginPage'e giderken arkadaki her şeyi (Splash dahil) SİL
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }
}
