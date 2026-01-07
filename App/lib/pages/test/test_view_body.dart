import 'package:flutter/material.dart';
import 'test_styles.dart';
import 'test_header.dart';
import 'question_card.dart';
import 'next_button.dart';

class TestViewBody extends StatelessWidget {
  final bool isDark;
  final String question;
  final int index;
  final int total;
  final int?
  selectedAnswer; // Bu değer AnswerRow'dan gelen -2 ile +2 arası puandır
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
    // Son soru kontrolü
    final bool isLast = index == total - 1;

    return Container(
      // Arka plan gradyanı
      decoration: BoxDecoration(
        gradient: TestStyles.getBackgroundGradient(isDark),
      ),
      child: Column(
        children: [
          // Üst başlık alanı (ProgressBar vb.)
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
                // AnswerRow'dan gelen gerçek MBTI puanını (-2, -1, 0, 1, 2)
                // doğrudan yukarıdaki onAnswer fonksiyonuna paslıyoruz.
                onAnswer: (int realMbtiValue) {
                  // Debug: Terminalde eksi değerleri görüp görmediğimizi kontrol edelim
                  print("Soru ${index + 1} için seçilen puan: $realMbtiValue");
                  onAnswer(realMbtiValue);
                },
              ),
            ),
          ),

          const SizedBox(height: 30),

          // İlerleme Butonu
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
