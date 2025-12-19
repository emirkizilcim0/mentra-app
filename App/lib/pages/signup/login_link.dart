import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginLink extends StatelessWidget {
  const LoginLink({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.pop(context),
      child: Text(
        "Already have an account? Log in",
        style: GoogleFonts.poppins(color: Colors.black87, fontSize: 13),
      ),
    );
  }
}
