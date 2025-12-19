import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mentra_app/pages/signup/signup_page.dart'; // Import yolunu kontrol et

class LoginLinks extends StatelessWidget {
  const LoginLinks({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            "Forgot Password?",
            style: GoogleFonts.poppins(color: Colors.black54, fontSize: 13),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SignupPage()),
            ),
            child: Text(
              "Signup !",
              style: GoogleFonts.poppins(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
