import 'package:flutter/material.dart';
import 'test_styles.dart';
import 'test_header.dart';
import 'question_card.dart';
import 'next_button.dart'; // Yeni NextButton dosyasını import et

class TestViewBody extends StatelessWidget {
  final bool isDark;
  final String question;
  final int index;
  final int total;
  final int? selectedAnswer;
  final ValueChanged<int> onAnswer;
  final VoidCallback onNext;

  const TestViewBody({
    super.key,
    required this.isDark,
    required this.question,
    required this.index,
    required this.total,
    required this.selectedAnswer,
    required this.onAnswer,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    // isLastQuestion kontrolü
    final bool isLast = index == total - 1;

    return Container(
      decoration: BoxDecoration(
        gradient: TestStyles.getBackgroundGradient(isDark),
      ),
      child: Column(
        children: [
          TestHeader(isDark: isDark),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: QuestionCard(
                question: question,
                index: index,
                total: total,
                selectedAnswer: selectedAnswer,
                isDark: isDark,
                onAnswer: onAnswer,
              ),
            ),
          ),
          const SizedBox(height: 30),
          NextButton(
            isSelected: selectedAnswer != null,
            isLastQuestion: isLast,
            isDark: isDark,
            onTap: onNext,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
