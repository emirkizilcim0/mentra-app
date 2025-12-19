// lib/custom_input_field.dart
import 'package:flutter/material.dart';
import 'info_theme_colors.dart';

class CustomInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isDark;

  const CustomInputField({
    required this.label,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            color: InfoColors.text(isDark),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 1.5,
          color: InfoColors.divider(isDark),
          margin: const EdgeInsets.only(bottom: 4),
        ),
        TextField(
          controller: controller,
          style: TextStyle(color: InfoColors.text(isDark)),
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: const EdgeInsets.only(top: 4),
            hintStyle: TextStyle(color: InfoColors.hint(isDark)),
          ),
        ),
      ],
    );
  }
}
