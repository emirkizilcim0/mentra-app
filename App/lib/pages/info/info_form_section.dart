// lib/info_form_section.dart
import 'package:flutter/material.dart';
import 'custom_input_field.dart';

class InfoFormSection extends StatelessWidget {
  final bool isDark;
  final List<TextEditingController> ctrls; // Name, Bday, Sign, Time

  const InfoFormSection({required this.isDark, required this.ctrls});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomInputField(label: "Name", controller: ctrls[0], isDark: isDark),
          const SizedBox(height: 25),
          CustomInputField(
            label: "Birthday",
            controller: ctrls[1],
            isDark: isDark,
          ),
          const SizedBox(height: 25),
          CustomInputField(label: "Sign", controller: ctrls[2], isDark: isDark),
          const SizedBox(height: 25),
          CustomInputField(
            label: "The time you born",
            controller: ctrls[3],
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}
