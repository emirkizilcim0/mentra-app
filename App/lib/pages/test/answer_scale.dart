import 'package:flutter/material.dart';
import 'answer_circle.dart';
import 'answer_data.dart'; // Renk ve boyut verileri için gerekli

class AnswerScale extends StatelessWidget {
  final int? selectedAnswer;
  final bool isDark;
  final ValueChanged<int> onSelect;

  const AnswerScale({
    super.key,
    required this.selectedAnswer,
    required this.isDark,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (index) {
            final int value = index + 1;
            return AnswerCircle(
              value: value,
              isSelected: selectedAnswer == value,
              size: AnswerData.getSize(index),
              baseColor: AnswerData.getColor(index),
              onTap: () => onSelect(value),
            );
          }),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Disagree",
              style: TextStyle(
                color: isDark ? Colors.red[300] : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Agree",
              style: TextStyle(
                color: isDark ? Colors.green[300] : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
