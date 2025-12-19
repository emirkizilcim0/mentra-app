import 'package:flutter/material.dart';
import 'package:mentra_app/pages/profile/birth_chart_section.dart';
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
  String mbtiTitle = "No result", mbtiDesc = "", mbtiType = "", birthDate = "";
  DateTime? selectedDate;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await ProfileLogic.loadData();
    setState(() {
      nameCtrl.text = data['name'] ?? "";
      signCtrl.text = data['zodiac'] ?? "";
      birthDate = data['birthDateStr'] ?? "";
      selectedDate = data['selectedDate'];
      mbtiTitle = data['mbtiTitle'] ?? "No result";
      mbtiDesc = data['mbtiDesc'] ?? "";
      mbtiType = data['mbtiType'] ?? "";
      loading = false;
    });
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
      final newZodiac = getZodiac(picked);
      await ProfileLogic.updateBirthData(picked, newZodiac);
      setState(() {
        selectedDate = picked;
        birthDate = DateFormat('d MMMM yyyy').format(picked);
        signCtrl.text = newZodiac;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    if (loading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

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
                          value: signCtrl.text,
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
                        MbtiSection(
                          title: mbtiTitle,
                          desc: mbtiDesc,
                          type: mbtiType,
                        ),
                        const SizedBox(height: 25),
                        const BirthChartSection(),
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
