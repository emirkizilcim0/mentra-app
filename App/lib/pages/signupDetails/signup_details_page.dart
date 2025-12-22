import 'package:flutter/material.dart';

// --- LOGIC IMPORT ---
// Eğer bu dosya kırmızı yanarsa, bir önceki adımda oluşturduğumuz
// 'signup_submission_logic.dart' dosyasının varlığından emin ol.
import 'package:mentra_app/pages/signupDetails/complete_button.dart';
import 'package:mentra_app/pages/signupDetails/date_picker_field.dart';
import 'package:mentra_app/pages/signupDetails/details_form_card.dart';
import 'package:mentra_app/pages/signupDetails/details_styles.dart';
import 'package:mentra_app/pages/signupDetails/details_title.dart';
import 'package:mentra_app/pages/signupDetails/signup_submission_logic.dart';
import 'package:mentra_app/pages/signupDetails/text_input_field.dart';

class SignupDetailsPage extends StatefulWidget {
  final String email;
  final String password;
  final bool isGoogle;

  const SignupDetailsPage({
    super.key,
    required this.email,
    required this.password,
    this.isGoogle = false,
  });

  @override
  State<SignupDetailsPage> createState() => _SignupDetailsPageState();
}

class _SignupDetailsPageState extends State<SignupDetailsPage> {
  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  DateTime? _birthDate;
  bool _isLoading = false;

  Future<void> _handleComplete() async {
    // 1. Basit Validasyon
    if (_firstCtrl.text.isEmpty ||
        _lastCtrl.text.isEmpty ||
        _birthDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields.')));
      return;
    }

    setState(() => _isLoading = true);

    bool success = false;
    if (widget.isGoogle) {
      success = await SignupSubmissionLogic.saveGoogleDetails(
        _firstCtrl.text.trim(),
        _lastCtrl.text.trim(),
        _birthDate!,
      );
    } else {
      success = await SignupSubmissionLogic.signUpAndSaveData(
        widget.email,
        widget.password,
        _firstCtrl.text.trim(),
        _lastCtrl.text.trim(),
        _birthDate!,
      );
    }

    if (mounted) setState(() => _isLoading = false);

    // 3. Sonuç Yönetimi
    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/testPage');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signup failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: DetailsStyles.gradientBackground, // Modüler Stil
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 100),
          child: Column(
            children: [
              const DetailsTitle(), // Modüler Başlık
              const SizedBox(height: 24),

              // Modüler Beyaz Kart
              DetailsFormCard(
                child: Column(
                  children: [
                    TextInputField(label: 'First Name', controller: _firstCtrl),
                    const SizedBox(height: 16),
                    TextInputField(label: 'Last Name', controller: _lastCtrl),
                    const SizedBox(height: 16),

                    DatePickerField(
                      date: _birthDate,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().subtract(
                            const Duration(days: 6570),
                          ), // ~18 yaş
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) setState(() => _birthDate = picked);
                      },
                    ),

                    const SizedBox(height: 24),

                    CompleteButton(
                      isLoading: _isLoading,
                      onPressed: _handleComplete,
                    ),
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
