// lib/pages/login/login_logic.dart
import 'package:flutter/material.dart';
import 'login_actions_email.dart';
import 'login_actions_google.dart';

class LoginLogic {
  // E-posta girişi için yardımcı sınıfı çağırır
  Future<void> login(
    BuildContext context,
    String email,
    String pass,
    Function(bool) setLoading,
  ) async {
    await EmailLoginAction.execute(context, email, pass, setLoading);
  }

  // Google girişi için yardımcı sınıfı çağırır
  Future<void> googleLogin(
    BuildContext context,
    Function(bool) setLoading,
  ) async {
    await GoogleLoginAction.execute(context, setLoading);
  }
}
