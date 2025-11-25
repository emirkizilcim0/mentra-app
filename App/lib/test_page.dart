import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'mbti/data/questions_data.dart';

// Test Sayfası Widget'ı
class MbtiTestPage extends StatefulWidget {
  const MbtiTestPage({super.key});

  @override
  State<MbtiTestPage> createState() => _MbtiTestPageState();
}

class _MbtiTestPageState extends State<MbtiTestPage> {
  int currentQuestionIndex = 0;
  int totalQuestions = 70;
  // Seçilen yanıt değeri (1'den 5'e kadar)
  int? selectedAnswer;

  final List<String> questions = [
    "At a party, I interact with many people, including strangers.",
    "I often get lost in thought when I'm alone.",
    "I make decisions based on logical reasoning.",
  ];

  void _goToNextQuestion() {
    setState(() {
      if (currentQuestionIndex < totalQuestions - 1) {
        currentQuestionIndex++;
        selectedAnswer = null; // Yeni soru için seçimi sıfırla
      } else {
        // Test bitti. Sonuç sayfasına yönlendir.
        // Navigator.of(context).pushReplacementNamed('/resultsPage');
        Navigator.of(context).pop(); // Geçici olarak geri dön
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = mbtiQuestions[currentQuestionIndex];
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.fromARGB(39, 253, 253, 253), Color(0xFFFFFFFF)],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text(
              "Mentra",
              style: GoogleFonts.pacifico(fontSize: 28, color: Colors.black87),
            ),
            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                height: 500,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(19, 229, 229, 230),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(31, 85, 0, 145),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: _buildQuestionCard(currentQuestion.question),
              ),
            ),

            const SizedBox(height: 30), // 🔼 TextButton yukarı alındı

            _buildNextButton(),
          ],
        ),
      ),
    );
  }

  // Başlık ve Geri Butonu

  // Soru Kartı
  Widget _buildQuestionCard(String questionText) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: [
          Container(
            alignment: Alignment.topLeft,
            child: Text(
              "Question ${currentQuestionIndex + 1}/$totalQuestions",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  questionText,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
              ],
            ),
          ),

          // YENİ DÜZENLENMİŞ YANIT SEÇENEKLERİ
          _buildAnswerOptions(),
          const SizedBox(height: 20),

          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "disagree", // En büyük daire (1)
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "agree", // En büyük daire (5)
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🔴 YANIT SEÇENEKLERİ DÜZENLENDİ (BOYUT VE RENK)
  Widget _buildAnswerOptions() {
    // 1. Daire Boyutları (En Büyük, Büyük, Küçük, Büyük, En Büyük)
    const List<double> sizes = [50.0, 40.0, 30.0, 40.0, 50.0];

    // 2. Renkler (Koyu Kırmızı, Açık Kırmızı, Nötr, Açık Yeşil, Koyu Yeşil)
    const List<Color> colors = [
      Color(0xFFD32F2F), // Koyu Kırmızı (disagree)
      Color(0xFFFFCDD2), // Açık Kırmızı
      Color(0xFF989898), // Nötr/Mavi (nötr)
      Color(0xFFC8E6C9), // Açık Yeşil
      Color(0xFF388E3C), // Koyu Yeşil (agree)
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(5, (index) {
        final int value = index + 1; // 1'den 5'e kadar değerler
        final double size = sizes[index]; // Boyutu listeden al
        final Color baseColor = colors[index]; // Temel rengi listeden al

        // Seçilen renk, temel renk veya beyaz (seçilmemişse)
        final Color circleColor = selectedAnswer == value
            ? baseColor
            : Colors.white;

        // Seçilmediyse sadece gri çerçeve, seçildiyse temel rengi çerçeve
        final Color borderColor = selectedAnswer == value
            ? baseColor
            : Colors.grey.shade400;

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedAnswer = value;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: circleColor,
              border: Border.all(color: borderColor, width: 2),
              boxShadow: selectedAnswer == value
                  ? [
                      BoxShadow(
                        // Seçilen daireye temel rengin hafif bir gölgesi
                        color: baseColor.withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
          ),
        );
      }),
    );
  }

  // İLERİ Butonu
  Widget _buildNextButton() {
    final bool isAnswerSelected = selectedAnswer != null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          // Gradient renkler (Pembe tonları)
          gradient: isAnswerSelected
              ? const LinearGradient(
                  colors: [Color(0xFFE91E63), Color(0xFFF06292)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: isAnswerSelected ? null : Colors.grey.shade300,
        ),
        child: Material(
          color: Colors.transparent,

          ///_goToNextQuestion
          child: InkWell(
            onTap: isAnswerSelected ? _goToNextQuestion : null,
            borderRadius: BorderRadius.circular(30),
            child: Center(
              child: Text(
                currentQuestionIndex < totalQuestions - 1 ? "NEXT" : "FINISH",
                style: TextStyle(
                  color: isAnswerSelected ? Colors.white : Colors.black54,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
