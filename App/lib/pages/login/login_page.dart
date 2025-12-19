import 'package:flutter/material.dart';
import 'package:mentra_app/pages/login/login_button.dart';
import 'package:mentra_app/pages/login/login_field.dart';
import 'package:mentra_app/pages/login/login_header.dart';
import 'package:mentra_app/pages/login/login_links.dart';
import 'package:mentra_app/pages/login/login_logic.dart';
import 'package:mentra_app/pages/login/login_styles.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final LoginLogic _logic = LoginLogic();
  bool _isLoading = false;

  void _setLoading(bool val) => setState(() => _isLoading = val);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: LoginStyles.gradientBackground,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 100),
          child: Column(
            children: [
              const LoginHeader(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                decoration: LoginStyles.cardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LoginField(
                      label: "EMAIL",
                      hint: "steveaustin@gmail.com",
                      controller: _emailCtrl,
                    ),
                    LoginField(
                      label: "PASSWORD",
                      hint: "******",
                      controller: _passCtrl,
                      isPassword: true,
                    ),
                    const SizedBox(height: 10),
                    LoginButtons(
                      isLoading: _isLoading,
                      onLogin: () => _logic.login(
                        context,
                        _emailCtrl.text.trim(),
                        _passCtrl.text.trim(),
                        _setLoading,
                      ),
                      onGoogleLogin: () =>
                          _logic.googleLogin(context, _setLoading),
                    ),
                    const SizedBox(height: 20),
                    const LoginLinks(),
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
