import 'package:flutter/material.dart';
import 'package:mentra_app/pages/signup/login_link.dart';
import 'package:mentra_app/pages/signup/signup_button.dart';
import 'package:mentra_app/pages/signup/signup_form_fields.dart';
import 'package:mentra_app/pages/signup/signup_header.dart';
import 'package:mentra_app/pages/signup/signup_styles.dart';
import 'package:mentra_app/pages/signupDetails/signup_flow_logic.dart';
// WIDGET IMPORTLARI

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _isLoading = false;

  void _onSignup() {
    setState(() => _isLoading = true);

    // YENİ LOGIC KULLANIMI:
    SignupFlowLogic.navigateToDetails(
      context,
      _emailCtrl.text.trim(),
      _passCtrl.text.trim(),
      _confirmCtrl.text.trim(),
    );

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: SignupStyles.backgroundGradient,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 100),
          child: Column(
            children: [
              const SignupHeader(),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: SignupStyles.formContainerDecoration,
                child: Column(
                  children: [
                    SignupFormFields(
                      emailCtrl: _emailCtrl,
                      passCtrl: _passCtrl,
                      confirmCtrl: _confirmCtrl,
                    ),
                    const SizedBox(height: 30),
                    SignupButton(isLoading: _isLoading, onPressed: _onSignup),
                    const SizedBox(height: 20),
                    const LoginLink(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
