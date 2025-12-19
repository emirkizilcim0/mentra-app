import 'package:flutter/material.dart';
import 'package:mentra_app/pages/signupDetails/signup_details_page.dart'; // import yolunu kontrol et

class SignupLogic {
  static void handleSignup(
    BuildContext context,
    String email,
    String pass,
    String confirm,
  ) {
    if (email.isEmpty || pass.isEmpty || confirm.isEmpty) {
      _showSnack(context, "Please fill all fields.");
      return;
    }
    if (pass != confirm) {
      _showSnack(context, "Passwords do not match.");
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SignupDetailsPage(email: email, password: pass),
      ),
    );
  }

  static void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  static Future signUpAndSaveData(
    String email,
    String password,
    String trim,
    String trim2,
    DateTime dateTime,
  ) async {}
}
