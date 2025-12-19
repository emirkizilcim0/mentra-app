import 'package:flutter/material.dart';
import 'answer_data.dart';
import 'answer_circle.dart';

class AnswerRow extends StatelessWidget {
  final int? selectedAnswer;
  final ValueChanged<int> onSelect;

  const AnswerRow({
    super.key,
    required this.selectedAnswer,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
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
    );
  }
}
