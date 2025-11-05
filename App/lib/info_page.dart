import 'package:flutter/material.dart';
import 'routes_manager.dart'; // It is hard-coded right now. Need to use routes_manager.dart.
import 'test_page.dart';
import 'chat_page.dart';
import 'package:google_fonts/google_fonts.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  final _nameController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _signController = TextEditingController();
  final _timeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with logo and chat icon
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFBFE5F5), Color(0xFFF9FAFB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Mentra",
                    style: GoogleFonts.pacifico(
                      fontSize: 28,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 80),

            // Info form fields
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInputField("Name", _nameController),
                  const SizedBox(height: 25),
                  _buildInputField("Birthday", _birthdayController),
                  const SizedBox(height: 25),
                  _buildInputField("Sign", _signController),
                  const SizedBox(height: 25),
                  _buildInputField("The time you born", _timeController),
                ],
              ),
            ),

            const SizedBox(height: 50),

            // Okay button
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MbtiTestPage()),
                );
              },
              child: Container(
                width: 160,
                height: 55,
                decoration: BoxDecoration(
                  color: const Color(0xFFB36A7A),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      offset: const Offset(0, 4),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    "Okay",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 1.5,
          color: Colors.grey.shade400,
          margin: const EdgeInsets.only(bottom: 4),
        ),
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.only(top: 4),
          ),
        ),
      ],
    );
  }
}
