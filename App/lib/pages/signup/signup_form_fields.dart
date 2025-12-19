import 'package:flutter/material.dart';
import 'signup_styles.dart';

class SignupFormFields extends StatelessWidget {
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final TextEditingController confirmCtrl;

  const SignupFormFields({
    super.key,
    required this.emailCtrl,
    required this.passCtrl,
    required this.confirmCtrl,
  });

  @override
  Widget build(BuildContext context) {
    const TextStyle textStyle = TextStyle(color: Colors.black);
    return Column(
      children: [
        TextField(
          controller: emailCtrl,
          style: textStyle,
          decoration: SignupStyles.inputDecoration("Email"),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: passCtrl,
          obscureText: true,
          style: textStyle,
          decoration: SignupStyles.inputDecoration("Password"),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: confirmCtrl,
          obscureText: true,
          style: textStyle,
          decoration: SignupStyles.inputDecoration("Confirm Password"),
        ),
      ],
    );
  }
}
