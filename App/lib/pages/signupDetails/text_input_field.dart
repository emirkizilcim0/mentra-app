import 'package:flutter/material.dart';

class TextInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const TextInputField({
    super.key,
    required this.label,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      // ÇÖZÜM: Yazı rengini siyah yapıyoruz
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        // Etiket rengini de belirginleştirelim
        labelStyle: const TextStyle(color: Colors.black54),
        border: const OutlineInputBorder(),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black26),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 2),
        ),
      ),
    );
  }
}
