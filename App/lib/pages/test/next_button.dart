import 'package:flutter/material.dart';
import 'next_button_style.dart'; // Aşağıdaki dosyayı import ediyoruz

class NextButton extends StatelessWidget {
  final bool isSelected; // Bir şık seçildi mi?
  final bool isLastQuestion; // Son soru mu?
  final bool isDark; // Karanlık mod mu?
  final VoidCallback onTap; // Tıklama fonksiyonu

  const NextButton({
    super.key,
    required this.isSelected,
    required this.isLastQuestion,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        height: 55,
        decoration: NextButtonStyle.getDecoration(isSelected, isDark),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isSelected ? onTap : null,
            borderRadius: BorderRadius.circular(30),
            child: Center(
              child: Text(
                isLastQuestion ? "FINISH" : "NEXT",
                style: NextButtonStyle.getTextStyle(isSelected, isDark),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
