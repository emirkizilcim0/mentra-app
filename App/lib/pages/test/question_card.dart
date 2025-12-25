import 'package:flutter/material.dart';
import 'test_styles.dart';
import 'question_text.dart';
import 'answer_row.dart';

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
    // Ekran boyutlarını alıyoruz
    final size = MediaQuery.of(context).size;
    final double screenWidth = size.width;
    final double screenHeight = size.height;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          // Padding değerini ekran genişliğine göre oranlıyoruz (%5)
          padding: EdgeInsets.all(screenWidth * 0.05),
          decoration: TestStyles.cardDecoration(isDark),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  children: [
                    // Soru numarası (Question 1/70)
                    QuestionTextDisplay(
                      text: "",
                      index: index,
                      total: total,
                      isDark: isDark,
                    ),

                    const Spacer(flex: 1), // Üst boşluk
                    // Ana Soru Metni
                    Text(
                      question,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        // Font boyutunu ekran genişliğine göre ayarlıyoruz
                        // 22px civarı başlar, küçük/büyük ekrana göre esner
                        fontSize: screenWidth * 0.055 > 24
                            ? 24
                            : screenWidth * 0.055,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                        height: 1.3, // Satır aralığı okunabilirliği artırır
                      ),
                    ),

                    const Spacer(
                      flex: 2,
                    ), // Alt boşluk (Soruyu biraz daha yukarı iter)
                  ],
                ),
              ),

              // Cevap şıkları (Boyutu kendi içinde esnektir)
              AnswerRow(selectedAnswer: selectedAnswer, onSelect: onAnswer),

              // Alt boşluk - Ekran yüksekliğine göre oranlı
              SizedBox(height: screenHeight * 0.025),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLabel("disagree", screenWidth),
                  _buildLabel("agree", screenWidth),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text, double screenWidth) {
    return Text(
      text,
      style: TextStyle(
        // Etiket fontunu da oranlıyoruz
        fontSize: screenWidth * 0.04 > 16 ? 16 : screenWidth * 0.04,
        fontWeight: FontWeight.w500,
        color: isDark ? Colors.grey[400] : Colors.grey,
      ),
    );
  }
}
