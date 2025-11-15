import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

String getZodiac(DateTime date) {
  int day = date.day;
  int month = date.month;

  if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return "Aries";
  if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return "Taurus";
  if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) return "Gemini";
  if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) return "Cancer";
  if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return "Leo";
  if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return "Virgo";
  if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) return "Libra";
  if ((month == 10 && day >= 23) || (month == 11 && day <= 21))
    return "Scorpio";
  if ((month == 11 && day >= 22) || (month == 12 && day <= 21))
    return "Sagittarius";
  if ((month == 12 && day >= 22) || (month == 1 && day <= 19))
    return "Capricorn";
  if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return "Aquarius";
  return "Pisces";
}

class SignupDetailsPage extends StatefulWidget {
  final String email;
  final String password;

  const SignupDetailsPage({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  State<SignupDetailsPage> createState() => _SignupDetailsPageState();
}

class _SignupDetailsPageState extends State<SignupDetailsPage> {
  final AuthService _authService = AuthService();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  DateTime? birthDate;
  bool isLoading = false;

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final initial = birthDate ?? DateTime(now.year - 18, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => birthDate = picked);
    }
  }

  Future<void> _completeSignup() async {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final bd = birthDate;

    if (firstName.isEmpty || lastName.isEmpty || bd == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields.')));
      return;
    }

    setState(() => isLoading = true);
    try {
      // Hesap oluşturma (Firebase Auth)
      final user = await _authService.signUpWithEmail(
        widget.email,
        widget.password,
      );
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signup failed. Try again.')),
        );
        setState(() => isLoading = false);
        return;
      }

      // Profil bilgilerini yerelde sakla (ileride Firestore’a yazmak için hazır)
      final zodiac = getZodiac(bd);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_zodiac', zodiac);
      await prefs.setString('profile_firstName', firstName);
      await prefs.setString('profile_lastName', lastName);
      await prefs.setString('profile_birthDateISO', bd.toIso8601String());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully!')),
      );
      Navigator.pushReplacementNamed(context, '/testPage');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String _formatDate(DateTime d) {
      final y = d.year.toString().padLeft(4, '0');
      final m = d.month.toString().padLeft(2, '0');
      final day = d.day.toString().padLeft(2, '0');
      return '$y-$m-$day';
    }

    final bdText = birthDate == null
        ? 'Select your birth date'
        : _formatDate(birthDate!);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFB3E5FC),
              Color(0xFFE1BEE7),
              Color(0xFFFFF9C4),
              Color(0xFFB2DFDB),
            ],
            stops: [0.1, 0.4, 0.7, 0.9],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Complete Your Profile',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: _pickBirthDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Birth Date',
                          border: OutlineInputBorder(),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              bdText,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            const Icon(
                              Icons.calendar_today,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _completeSignup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD68DA8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Complete Sign Up',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                      ),
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
