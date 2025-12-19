import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mentra_app/pages/profile/daily_horoscope_section.dart';
import 'package:mentra_app/pages/profile/logout_button.dart';
import 'package:mentra_app/pages/profile/mbti_section.dart';
import 'package:mentra_app/pages/profile/profile_avatar_section.dart';
import 'package:mentra_app/pages/profile/profile_bottom_nav.dart';
import 'package:mentra_app/pages/profile/profile_card_container.dart';
import 'package:mentra_app/pages/profile/profile_field.dart';
import 'package:mentra_app/pages/profile/profile_text_field.dart';
import 'package:mentra_app/pages/profile/profile_top_bar.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:mentra_app/providers/theme_provider.dart';

// Logic ve Yardımcılar
import 'profile_logic.dart';
import 'profile_save_logic.dart';
import 'profile_helpers.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final nameCtrl = TextEditingController();
  final signCtrl = TextEditingController();

  // Varsayılan değerleri "Loading..." veya boş olarak ayarladım
  String mbtiTitle = "Analiz Ediliyor...", mbtiDesc = "", mbtiType = "";
  String birthDate = "";
  DateTime? selectedDate;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (mounted && doc.exists) {
        final data = doc.data() as Map<String, dynamic>;

        setState(() {
          // 1. İsim
          String foundName = "";
          if (data['firstName'] != null &&
              data['firstName'].toString().isNotEmpty) {
            foundName = data['firstName'];
            if (data['lastName'] != null) foundName += " ${data['lastName']}";
          } else if (data['name'] != null) {
            foundName = data['name'];
          } else if (data['username'] != null) {
            foundName = data['username'];
          }
          nameCtrl.text = foundName;

          // 2. Burç
          signCtrl.text = data['sign'] ?? data['zodiac'] ?? "";

          // 3. Tarih
          dynamic birthData = data['birthDate'] ?? data['birthDateStr'];
          DateTime? dt;

          try {
            if (birthData is Timestamp) {
              dt = birthData.toDate();
            } else if (birthData is String) {
              dt = DateTime.tryParse(birthData);
              dt ??= _tryParseFormattedDate(birthData);
            }

            if (dt != null) {
              birthDate = DateFormat('d MMMM yyyy').format(dt);
              selectedDate = dt;
            }
          } catch (e) {
            debugPrint("Date parsing error: $e");
            birthDate = birthData?.toString() ?? "";
          }

          // 4. MBTI (GÜNCELLENMİŞ KISIM)
          // "Testi Çöz" mantığını kaldırdık. Kullanıcının zaten bir sonucu olmalı.
          if (data['mbtiResult'] != null || data['mbtiType'] != null) {
            mbtiTitle = data['mbtiTitle'] ?? "Sonucunuz";
            mbtiDesc = data['mbtiDesc'] ?? "";
            mbtiType = data['mbtiType'] ?? data['mbtiResult'] ?? "";
          } else {
            // Veri gelmezse fallback (Yine de "Testi Çöz" demiyoruz)
            mbtiTitle = "MBTI Result";
            mbtiDesc = "";
            mbtiType = "Unknown";
          }

          loading = false;
        });
      } else {
        if (mounted) setState(() => loading = false);
      }
    } catch (e) {
      debugPrint("Veri yükleme hatası: $e");
      if (mounted) setState(() => loading = false);
    }
  }

  DateTime? _tryParseFormattedDate(String dateStr) {
    if (dateStr.isEmpty) return null;
    try {
      return DateFormat('d MMMM yyyy').parse(dateStr);
    } catch (_) {
      return null;
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime(now.year - 18),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      try {
        final newZodiac = getZodiac(picked);
        await ProfileLogic.updateBirthData(picked, newZodiac);

        if (mounted) {
          setState(() {
            selectedDate = picked;
            birthDate = DateFormat('d MMMM yyyy').format(picked);
            signCtrl.text = newZodiac;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Birth date updated successfully!"),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Failed to update birth date."),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Column(
            children: [
              ProfileTopBar(
                themeProvider: themeProvider,
                onSave: () => ProfileSaveLogic.save(context, nameCtrl.text),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 90),
                  child: ProfileCardContainer(
                    child: Column(
                      children: [
                        const ProfileAvatarSection(),
                        ProfileTextField(label: "Name", controller: nameCtrl),
                        const SizedBox(height: 12),
                        ProfileField(
                          label: "Zodiac",
                          value: signCtrl.text.isNotEmpty
                              ? signCtrl.text
                              : "Not set",
                          icon: Icons.stars,
                          isDark: isDark,
                        ),
                        ProfileField(
                          label: "Birth Date",
                          value: birthDate,
                          icon: Icons.cake,
                          isDark: isDark,
                          onTap: _pickDate,
                        ),
                        const SizedBox(height: 20),

                        // MBTI Section'ı sadece veri varsa veya varsayılan değerle göster
                        MbtiSection(
                          title: mbtiTitle,
                          desc: mbtiDesc,
                          type: mbtiType,
                        ),

                        const SizedBox(height: 25),
                        const DailyHoroscopeSection(),
                        const LogoutButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const ProfileBottomNav(),
        ],
      ),
    );
  }
}
