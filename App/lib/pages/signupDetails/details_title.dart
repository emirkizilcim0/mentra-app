import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailsTitle extends StatelessWidget {
  const DetailsTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Complete Your Profile',
      style: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }
}
