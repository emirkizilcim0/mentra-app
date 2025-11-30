import 'package:flutter/material.dart';
import 'routes_manager.dart'; // It is hard-coded right now. Need to use routes_manager.dart.
import 'test_page.dart';
import 'chat_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';

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
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode
          ? const Color(0xFF121212) // Dark mode background
          : const Color(0xFFF9FAFB), // Light mode background
      body: Stack(
        children: [
          // Katman 1: Ana İçerik
          Column(
            children: [
              // 1. SABİT ÜST KISIM (Top Bar) - Floating Action Button ile
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Mentra Yazısı (Şeffaf FAB)
                      FloatingActionButton.extended(
                        heroTag: 'mentraTitle',
                        onPressed: () {},
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        label: Text(
                          "Mentra",
                          style: GoogleFonts.pacifico(
                            fontSize: 28,
                            color: themeProvider.isDarkMode
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),
                      ),

                      // Chat FAB (Küçük FAB)
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 80),

              // Info form fields
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputField("Name", _nameController, themeProvider),
                    const SizedBox(height: 25),
                    _buildInputField(
                      "Birthday",
                      _birthdayController,
                      themeProvider,
                    ),
                    const SizedBox(height: 25),
                    _buildInputField("Sign", _signController, themeProvider),
                    const SizedBox(height: 25),
                    _buildInputField(
                      "The time you born",
                      _timeController,
                      themeProvider,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 50),

              // Okay button
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MbtiTestPage(),
                    ),
                  );
                },
                child: Container(
                  width: 160,
                  height: 55,
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode
                        ? const Color(0xFFD68DA8) // Dark mode button
                        : const Color(0xFFB36A7A), // Light mode button
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: themeProvider.isDarkMode
                            ? Colors.black.withOpacity(0.5)
                            : Colors.black26,
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
        ],
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    ThemeProvider themeProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 1.5,
          color: themeProvider.isDarkMode
              ? Colors.grey.shade600
              : Colors.grey.shade400,
          margin: const EdgeInsets.only(bottom: 4),
        ),
        TextField(
          controller: controller,
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: const EdgeInsets.only(top: 4),
            hintStyle: TextStyle(
              color: themeProvider.isDarkMode
                  ? Colors.grey.shade400
                  : Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }
}
