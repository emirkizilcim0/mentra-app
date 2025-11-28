import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:mentra_app/mbti/result_screen.dart';
import 'home_page.dart';

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

  @override
  void initState() {
    super.initState();
    loadProfileData();
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

  // --- Floating Action Button Helper Fonksiyonu ---
  Widget _buildFab({
    required IconData icon,
    required VoidCallback onPressed,
    Color color = const Color(0xFFB3E5FC),
    double size = 30,
  }) {
    return FloatingActionButton(
      heroTag: icon.codePoint.toString(), // Her FAB için benzersiz tag gerekli
      shape: const CircleBorder(),
      backgroundColor: color,
      mini: size < 40, // Küçük FAB için mini: true kullanırız
      onPressed: onPressed,
      child: Icon(icon, size: size * 0.9, color: Colors.black87),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F4F9),
      body: Stack(
        children: [
          // Katman 1: Ana İçerik
          Column(
            children: [
              // 1. SABİT ÜST KISIM (Top Bar) - SafeArea ile değiştirildi
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
                      // Mentra Yazısı - Normal Container
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Text(
                          "Mentra",
                          style: GoogleFonts.pacifico(
                            fontSize: 28,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      // Save Butonu - Blur efekti ile
                      ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.save,
                                color: Colors.black87,
                                size: 24,
                              ),
                              onPressed: saveProfileData,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. KAYDIRILABİLİR PROFİL İÇERİĞİ
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 90), // Alt boşluk
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.black12, width: 1.5),
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
                          ),
                        ),
                        const SizedBox(height: 10),

                        // ---------------- FIELDS ----------------
                        _buildField("Name", nameController),
                        const SizedBox(height: 12),

                        // Zodiac Field (Read-only)
                        TextField(
                          controller: signController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: "Zodiac / Sign",
                            filled: true,
                            fillColor: const Color(0xFFF9FBFC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            suffixIcon: const Icon(Icons.lock, size: 16),
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
                                fillColor: const Color(0xFFF9FBFC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                suffixIcon: const Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ---------------- MBTI RESULT ----------------
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9DDE2),
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
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                mbtiDesc,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.black54,
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
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: Text(
                            "Your birth chart information will appear here.",
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.black54,
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

          // =========================================================
          // 3. SABİT ALT KISIM (FAB NAVİGASYON BUTONLARI - 4 TANE)
          // =========================================================
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
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // 1. Home Button
                        IconButton(
                          icon: const Icon(Icons.home, color: Colors.black87),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomePage(),
                              ),
                            );
                          },
                        ),

                        // 2. Advice Button
                        IconButton(
                          icon: const Icon(
                            Icons.lightbulb_outline,
                            color: Colors.black87,
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

                        // 3. Mood Track Button
                        IconButton(
                          icon: const Icon(
                            Icons.emoji_emotions_outlined,
                            color: Colors.black87,
                          ),
                          onPressed: () {
                            // Mood Track Sayfasına yönlendirme
                          },
                        ),

                        // 4. Profile Button
                        IconButton(
                          icon: const Icon(
                            Icons.person_outline,
                            color: Colors.black87,
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

  Widget _buildField(String label, TextEditingController c) {
    return TextField(
      controller: c,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF9FBFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
