import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginButtons extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onLogin;
  final VoidCallback onGoogleLogin;

  const LoginButtons({
    super.key,
    required this.isLoading,
    required this.onLogin,
    required this.onGoogleLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: ElevatedButton(
            onPressed: isLoading ? null : onLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD68DA8),
              padding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 100,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    "Log in",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 30),
        Text(
          "LOG IN WITH",
          style: GoogleFonts.poppins(color: Colors.black54, fontSize: 13),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: isLoading ? null : onGoogleLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF3C7CF),
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
          ),
          child: Text(
            "G",
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }
}
