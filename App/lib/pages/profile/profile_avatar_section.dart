import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileAvatarSection extends StatelessWidget {
  const ProfileAvatarSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFF48FB1), width: 3),
          ),
          child: const CircleAvatar(
            radius: 50,
            backgroundColor: Color(0xFFF8BBD0),
            child: Icon(Icons.person, size: 60, color: Colors.white),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          "Your Profile",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
