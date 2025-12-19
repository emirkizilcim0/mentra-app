import 'package:flutter/material.dart';
import 'test_styles.dart';
import 'question_text.dart';
import 'answer_row.dart'; // Yeni AnswerRow importu

class QuestionCard extends StatelessWidget {
  final String question;
  final int index;
  final int total;
  final int? selectedAnswer;
  final bool isDark;
  final ValueChanged<int> onAnswer;

  const QuestionCard({
    super.key,
    required this.question,
    required this.index,
    required this.total,
    required this.selectedAnswer,
    required this.isDark,
    required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: TestStyles.cardDecoration(isDark),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: QuestionTextDisplay(
                text: question,
                index: index,
                total: total,
                isDark: isDark,
              ),
            ),
          ),
          AnswerRow(selectedAnswer: selectedAnswer, onSelect: onAnswer),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "disagree",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey[400] : Colors.grey,
                ),
              ),
              Text(
                "agree",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey[400] : Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
