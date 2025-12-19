// lib/result_display.dart
import 'package:flutter/material.dart';

class ResultDisplay extends StatelessWidget {
  final String text;

  const ResultDisplay({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade50,
      ),
      child: SingleChildScrollView(
        child: Text(text, style: TextStyle(fontSize: 16, height: 1.5)),
      ),
    );
  }
}
