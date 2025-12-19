import 'package:flutter/material.dart';

class QuestionTextDisplay extends StatelessWidget {
  final String text;
  final int index;
  final int total;
  final bool isDark;

  const QuestionTextDisplay({
    super.key,
    required this.text,
    required this.index,
    required this.total,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Text(
            "Question ${index + 1}/$total",
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }
}
