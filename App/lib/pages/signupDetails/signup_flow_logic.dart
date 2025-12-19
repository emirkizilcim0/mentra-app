import 'package:flutter/material.dart';
// signup_details_page.dart dosyasının doğru yerde olduğundan emin olmalısın
import 'package:mentra_app/pages/signupDetails/signup_details_page.dart';

class SignupFlowLogic {
  static void navigateToDetails(
    BuildContext context,
    String email,
    String password,
    String confirmPassword,
  ) {
    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields.")));
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match.")));
      return;
    }

    // Detay sayfasına yönlendirme
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SignupDetailsPage(email: email, password: password),
      ),
    );
  }
}
