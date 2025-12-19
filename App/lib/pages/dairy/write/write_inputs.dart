import 'package:flutter/material.dart';
import 'write_styles.dart';

class TitleInput extends StatelessWidget {
  final TextEditingController controller;
  const TitleInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: WriteStyles.titleStyle,
      decoration: InputDecoration(
        hintText: 'Title',
        hintStyle: WriteStyles.hintStyle,
        border: InputBorder.none,
      ),
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'Write a title' : null,
    );
  }
}

class ContentInput extends StatelessWidget {
  final TextEditingController controller;
  const ContentInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: WriteStyles.contentStyle,
      maxLines: null,
      minLines: 10,
      decoration: InputDecoration(
        hintText: 'How was your day?',
        hintStyle: WriteStyles.hintStyle,
        border: InputBorder.none,
      ),
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'Write something' : null,
    );
  }
}
