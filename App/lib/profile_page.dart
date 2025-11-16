import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController signController = TextEditingController();

  String mbtiTitle = "No result yet";
  String mbtiDesc = "";
  String zodiac = "";
  String birthDate = "";

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? "unknown";

  String _key(String key) => "${key}_$_uid"; // namespaced key

  @override
  void initState() {
    super.initState();
    loadProfileData();
  }

  Future<void> loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      // Combine first + last name
      final firstName = prefs.getString(_key("profile_firstName")) ?? "";
      final lastName = prefs.getString(_key("profile_lastName")) ?? "";
      nameController.text = "$firstName $lastName";

      // Zodiac / Sign
      zodiac = prefs.getString(_key("profile_zodiac")) ?? "";
      signController.text = zodiac;

      // Birth date
      String birthDateIso = prefs.getString(_key("profile_birthDateISO")) ?? "";
      if (birthDateIso.isNotEmpty) {
        try {
          DateTime birth = DateTime.parse(birthDateIso);
          birthDate = DateFormat('d MMMM yyyy').format(birth);
        } catch (e) {
          birthDate = birthDateIso; // fallback
        }
      } else {
        birthDate = "";
      }

      // MBTI result
      mbtiTitle = prefs.getString(_key("profile_mbtiTitle")) ?? "No result yet";
      mbtiDesc = prefs.getString(_key("profile_mbtiDesc")) ?? "";
    });
  }

  Future<void> saveProfileData() async {
    final prefs = await SharedPreferences.getInstance();

    // Save name
    final fullName = nameController.text.split(" ");
    if (fullName.isNotEmpty) {
      await prefs.setString(_key("profile_firstName"), fullName[0]);
      await prefs.setString(
        _key("profile_lastName"),
        fullName.length > 1 ? fullName[1] : "",
      );
    }

    await prefs.setString(_key("profile_zodiac"), signController.text);
    // Optional: save birthDateISO if user edits birth date
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F4F9),
      body: SafeArea(
        child: Column(
          children: [
            // ---------------- TOP BAR ----------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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

            // ---------------- PROFILE CARD ----------------
            Expanded(
              child: SingleChildScrollView(
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
                      _buildField("Zodiac / Sign", signController),
                      const SizedBox(height: 12),
                      _buildField(
                        "Birth Date",
                        TextEditingController()..text = birthDate,
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
                            Text(
                              "$mbtiTitle",
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
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
                            Navigator.pushReplacementNamed(
                              context,
                              '/login',
                            ); // make sure /login route exists
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

            // ---------------- BOTTOM NAV ----------------
            Container(
              height: 65,
              decoration: const BoxDecoration(
                color: Color(0xFFD0E8EF),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.home_outlined, size: 28),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomePage(),
                        ),
                      );
                    },
                  ),
                  const Icon(Icons.person, size: 28),
                ],
              ),
            ),
          ],
        ),
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
