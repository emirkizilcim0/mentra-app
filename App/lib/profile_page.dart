import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:mentra_app/mbti/result_screen.dart';
import 'home_page.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'mood_graph_page.dart';

// Diğer kodlarınız aynı kalacak...
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

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController signController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String mbtiTitle = "No result yet";
  String mbtiDesc = "";
  String mbtiType = "";
  String zodiac = "";
  String birthDate = "";
  DateTime? selectedBirthDate;

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? "unknown";
  late Future<void> _loadingFuture;

  @override
  void initState() {
    super.initState();
    _loadingFuture = loadProfileData();
  }

  Future<void> loadProfileData() async {
    try {
      final doc = await _firestore.collection('users').doc(_uid).get();

      if (doc.exists) {
        final data = doc.data()!;

        setState(() {
          // Combine first + last name
          final firstName = data['firstName'] ?? "";
          final lastName = data['lastName'] ?? "";
          nameController.text = "$firstName $lastName";

          // Zodiac / Sign
          zodiac = data['zodiac'] ?? "";
          signController.text = zodiac;

          // Birth date
          String birthDateIso = data['birthDate'] ?? "";
          if (birthDateIso.isNotEmpty) {
            try {
              selectedBirthDate = DateTime.parse(birthDateIso);
              birthDate = DateFormat('d MMMM yyyy').format(selectedBirthDate!);
            } catch (e) {
              birthDate = birthDateIso;
            }
          } else {
            birthDate = "";
          }

          // MBTI result
          mbtiTitle = data['mbtiTitle'] ?? "No result yet";
          mbtiDesc = data['mbtiDesc'] ?? "";
          mbtiType = data['mbtiType'] ?? "";
        });
      }
    } catch (e) {
      print("Error loading profile data: $e");
    }
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final initial =
        selectedBirthDate ?? DateTime(now.year - 18, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (picked != null) {
      final newZodiac = getZodiac(picked);

      setState(() {
        selectedBirthDate = picked;
        birthDate = DateFormat('d MMMM yyyy').format(picked);
        zodiac = newZodiac;
        signController.text = newZodiac;
      });

      // Auto-save the new birth date and zodiac
      await _saveBirthDateAndZodiac(picked, newZodiac);
    }
  }

  Future<void> _saveBirthDateAndZodiac(
    DateTime birthDate,
    String zodiac,
  ) async {
    try {
      await _firestore.collection('users').doc(_uid).set({
        'birthDate': birthDate.toIso8601String(),
        'zodiac': zodiac,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Birth date updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating birth date: $e')));
    }
  }

  Future<void> saveProfileData() async {
    try {
      final fullName = nameController.text.split(" ");
      String firstName = "";
      String lastName = "";

      if (fullName.isNotEmpty) {
        firstName = fullName[0];
        lastName = fullName.length > 1 ? fullName[1] : "";
      }

      await _firestore.collection('users').doc(_uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    print(
      'ProfilePage building with dark mode: ${themeProvider.isDarkMode}',
    ); // Debug

    return Scaffold(
      backgroundColor: Theme.of(
        context,
      ).scaffoldBackgroundColor, // Dinamik renk
      body: Stack(
        children: [
          // Katman 1: Ana İçerik
          Column(
            children: [
              // 1. SABİT ÜST KISIM (Top Bar)
              SafeArea(
                bottom: false,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Mentra Yazısı
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Text(
                          "Mentra",
                          style: GoogleFonts.pacifico(
                            fontSize: 28,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                        ),
                      ),
                      // Theme ve Save Butonları
                      Row(
                        children: [
                          // Theme Toggle Button
                          _buildBlurIconButton(
                            icon: themeProvider.isDarkMode
                                ? Icons.light_mode
                                : Icons.dark_mode,
                            onPressed: () {
                              print('Toggling theme...'); // Debug
                              themeProvider.toggleTheme();
                            },
                          ),
                          const SizedBox(width: 8),
                          // Save Butonu
                          _buildBlurIconButton(
                            icon: Icons.save,
                            onPressed: saveProfileData,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 2. KAYDIRILABİLİR PROFİL İÇERİĞİ
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 90),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        // AVATAR
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFF48FB1),
                              width: 3,
                            ),
                          ),
                          child: const CircleAvatar(
                            radius: 50,
                            backgroundColor: Color(0xFFF8BBD0),
                            child: Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.white,
                            ),
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

                        // ---------------- FIELDS ----------------
                        _buildField("Name", nameController, context),
                        const SizedBox(height: 12),

                        // Zodiac Field (Read-only)
                        TextField(
                          controller: signController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: "Zodiac / Sign",
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            suffixIcon: const Icon(Icons.lock, size: 16),
                            labelStyle: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Birth Date Field (Clickable)
                        InkWell(
                          onTap: _pickBirthDate,
                          child: IgnorePointer(
                            child: TextField(
                              controller: TextEditingController()
                                ..text = birthDate,
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: "Birth Date",
                                filled: true,
                                fillColor: Theme.of(
                                  context,
                                ).colorScheme.surface,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                suffixIcon: const Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                ),
                                labelStyle: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ---------------- MBTI RESULT ----------------
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.pink[900]!.withOpacity(0.3)
                                : const Color(0xFFF9DDE2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ResultScreen(
                                        scores: const {},
                                        onRetakeTest: () {
                                          Navigator.pop(context);
                                          Navigator.pushNamed(
                                            context,
                                            "/testPage",
                                          );
                                        },
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  mbtiType.isNotEmpty
                                      ? "$mbtiType - $mbtiTitle"
                                      : mbtiTitle,
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onBackground,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                mbtiDesc,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, "/testPage");
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF48FB1),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Text("Retake"),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 25),

                        // ---------------- BIRTH CHART ----------------
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Birth Chart",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            "Your birth chart information will appear here.",
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ---------------- LOGOUT BUTTON ----------------
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                              if (!mounted) return;
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD68DA8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Log Out',
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
                ),
              ),
            ],
          ),

          // 3. SABİT ALT KISIM (Navigation)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.black.withOpacity(0.3)
                          : Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withOpacity(0.2)
                            : Colors.white.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.home,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomePage(),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.lightbulb_outline,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AdvicePage(),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.emoji_emotions_outlined,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MoodGraphPage(),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.person_outline,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController c,
    BuildContext context,
  ) {
    return TextField(
      controller: c,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      ),
    );
  }

  Widget _buildBlurIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withOpacity(0.3)
                : Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.2)
                  : Colors.white.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: IconButton(
            icon: Icon(
              icon,
              color: Theme.of(context).colorScheme.onBackground,
              size: 24,
            ),
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }
}
