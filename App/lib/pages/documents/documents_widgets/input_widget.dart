// lib/input_widget.dart
import 'package:flutter/material.dart';

class InputWidget extends StatelessWidget {
  final TextEditingController controller;

  const InputWidget({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 4,
      decoration: InputDecoration(
        labelText: 'Enter your text for analysis',
        border: OutlineInputBorder(),
        hintText:
            'Type or paste your thoughts, diary entry, or any text you want to analyze...',
      ),
    );
  }
}
