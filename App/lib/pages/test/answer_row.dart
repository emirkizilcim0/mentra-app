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
    // MBTI Testinde 5'li likert ölçeği değerleri:
    // Index 0: -2 (Strongly Disagree)
    // Index 1: -1 (Disagree)
    // Index 2:  0 (Neutral)
    // Index 3:  1 (Agree)
    // Index 4:  2 (Strongly Agree)
    final List<int> mbtiValues = [-2, -1, 0, 1, 2];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(5, (index) {
        // Artik value 1,2,3,4,5 degil; -2,-1,0,1,2 gidiyor
        final int actualValue = mbtiValues[index];

        return AnswerCircle(
          value: actualValue,
          isSelected: selectedAnswer == actualValue,
          size: AnswerData.getSize(index),
          baseColor: AnswerData.getColor(index),
          onTap: () => onSelect(actualValue), // Gercek MBTI puanini gonder
        );
      }),
    );
  }
}
