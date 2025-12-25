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
    // Ekran yüksekliğini alarak boşlukları dinamik yapıyoruz
    final double screenHeight = MediaQuery.of(context).size.height;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Üst Boşluk: Question yazısını kutunun tavanından aşağı indirir
        // Ekran yüksekliğinin %4'ü kadar pay bırakır (Yaklaşık 30-35px)
        SizedBox(height: screenHeight * 0.04),

        Align(
          alignment: Alignment.topLeft,
          child: Text(
            "Question ${index + 1}/$total",
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // 2. Orta Boşluk: Soru numarası ile soru metni arasındaki mesafe
        // Burayı biraz daraltarak (15px) bütünlüğü koruyoruz
        const SizedBox(height: 15),

        // Not: 'text' parametresi QuestionCard içinden boş geliyorsa
        // burası sadece üst kısmı yönetir.
        if (text.isNotEmpty)
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
