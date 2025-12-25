import 'package:flutter/material.dart';
import 'write_styles.dart';

class TitleInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark; // 1. Tema parametresi eklendi

  const TitleInput({
    super.key,
    required this.controller,
    required this.isDark, // 2. Zorunlu hale getirildi
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      // 3. Mevcut stili temaya göre renklendiriyoruz
      style: WriteStyles.titleStyle.copyWith(
        color: isDark ? Colors.white : Colors.black87,
      ),
      decoration: InputDecoration(
        hintText: 'Title',
        hintStyle: WriteStyles.hintStyle.copyWith(
          color: isDark ? Colors.white54 : Colors.black38,
        ),
        border: InputBorder.none,
      ),
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'Write a title' : null,
    );
  }
}

class ContentInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark; // 1. Tema parametresi eklendi

  const ContentInput({
    super.key,
    required this.controller,
    required this.isDark, // 2. Zorunlu hale getirildi
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      // 3. Mevcut stili temaya göre renklendiriyoruz
      style: WriteStyles.contentStyle.copyWith(
        color: isDark ? Colors.white : Colors.black87,
      ),
      maxLines: null,
      minLines: 10,
      decoration: InputDecoration(
        hintText: 'How was your day?',
        hintStyle: WriteStyles.hintStyle.copyWith(
          color: isDark ? Colors.white54 : Colors.black38,
        ),
        border: InputBorder.none,
      ),
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'Write something' : null,
    );
  }
}
