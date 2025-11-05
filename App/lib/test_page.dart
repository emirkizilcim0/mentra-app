import 'package:flutter/material.dart';
import 'package:mentra_app/mbti/personality_data.dart';
import 'package:mentra_app/mbti/result_screen.dart';
// Doğru yolları kullandığınızı varsayarak
import 'bar_widgets/custom_header.dart';
import 'mbti/data/questions_data.dart';
import 'mbti/services/mbti_calculator.dart'; // Hesaplayıcıyı import et
import 'mbti/models/question.dart';
// Diğer gerekli import'lar...

class MbtiTestPage extends StatefulWidget {
  const MbtiTestPage({super.key});

  @override
  State<MbtiTestPage> createState() => _MbtiTestPageState();
}

class _MbtiTestPageState extends State<MbtiTestPage> {
  // Testin durumunu yöneten değişkenler
  int _currentQuestionIndex = 0; // Sorular 0. indeksten başlar
  final int _totalQuestions = mbtiQuestions.length; // Toplam soru sayısı 70

  // Seçilen yanıtın **puan değeri** (JSON'daki Choice.value)
  int? _selectedScoreValue;

  // Hesaplama mantığını tutan sınıfın örneği
  final MbtiCalculator _calculator = MbtiCalculator();

  // Yeni butonu kullanmak için, eski 'questions' listesini silebilirsiniz.
  // final List<String> questions = [...]; // Bu listeye artık gerek yok

  void _goToNextQuestion() {
    // 1. Cevap verilmiş mi kontrol et
    if (_selectedScoreValue == null) return;

    // 2. Mevcut sorunun verisini al
    final Question currentQuestion = mbtiQuestions[_currentQuestionIndex];

    // 3. Hesaplamayı yap: scoreType (E, S, T, J) ve puanı (_selectedScoreValue) gönder
    _calculator.addScore(currentQuestion.scoreType, _selectedScoreValue!);

    // 4. Durumu güncelle (setState)
    setState(() {
      // Soru indeksini artır
      _currentQuestionIndex++;
      // Seçimi sıfırla
      _selectedScoreValue = null;
    });

    // 5. Kontrol ve Geçiş
    if (_currentQuestionIndex >= _totalQuestions) {
      // Test bitti. Sonucu hesapla ve sonuç sayfasına git.
      final String resultString = _calculator.calculateResult();
      final PersonalityResult personalityResult = PersonalityResult(
        // required fields expected by the constructor
        type: resultString,
        title: 'Your MBTI: $resultString',
        description: 'This result represents your MBTI type: $resultString',
        color: Colors.teal,
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            result: personalityResult, // PersonalityResult bekleniyor
            scores: _calculator.scores,
            onRetakeTest: () {
              // Restart the test by replacing the result screen with a fresh test page
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const MbtiTestPage()),
              );
            },
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );
    }
  }

  // --- Widget Build Metotları ---

  @override
  Widget build(BuildContext context) {
    // Testin bitip bitmediğini kontrol et
    final bool isTestFinished = _currentQuestionIndex >= _totalQuestions;

    return Scaffold(
      body: Container(
        // ... (Aynı Gradient Ayarları) ...
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE0F7FA), Color(0xFFFFFFFF)],
          ),
        ),
        child: Column(
          children: [
            const CustomHeader(),
            const SizedBox(height: 50),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: isTestFinished
                    ? _buildFinishCard() // Test bittiyse sonuç ekranını göster
                    : _buildQuestionCard(
                        mbtiQuestions[_currentQuestionIndex],
                      ), // Aksi halde soruyu göster
              ),
            ),
            _buildNextButton(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Test bittiğinde gösterilecek geçici kart
  Widget _buildFinishCard() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 80,
            color: Color(0xFFE91E63),
          ),
          const SizedBox(height: 20),
          Text(
            'Test Tamamlandı!',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Soru Kartı: Question nesnesini parametre olarak alacak şekilde güncellendi
  Widget _buildQuestionCard(Question currentQuestion) {
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
      padding: const EdgeInsets.all(25.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Question ${_currentQuestionIndex + 1}/$_totalQuestions", // Index + 1
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            currentQuestion.question, // Gerçek soru metni
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          // Cevap seçeneklerini question nesnesindeki choices listesiyle oluştur
          _buildAnswerOptions(currentQuestion.choices),

          const SizedBox(height: 20),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Strongly Disagree",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "Strongly Agree",
                style: TextStyle(
                  fontSize: 14,
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

  // YANIT SEÇENEKLERİ DÜZENLENDİ (Puanları kullanacak)
  Widget _buildAnswerOptions(List<Choice> choices) {
    // `Choice` nesnelerinin value'larını (puanlarını) kullanarak listeyi oluştur.
    // JSON'da value: -2, -1, 0, 1, 2 olarak gidiyor.

    const List<double> sizes = [50.0, 40.0, 30.0, 40.0, 50.0];
    const List<Color> colors = [
      Color(0xFFD32F2F), // Koyu Kırmızı (value: -2)
      Color(0xFFFFCDD2), // Açık Kırmızı (value: -1)
      Color(0xFF989898), // Nötr (value: 0)
      Color(0xFFC8E6C9), // Açık Yeşil (value: 1)
      Color(0xFF388E3C), // Koyu Yeşil (value: 2)
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: choices.map((choice) {
        final int scoreValue = choice.value; // -2'den +2'ye değer
        // index'i 0-4 arasına getirmek için +2 eklenir (örn: -2+2=0, 2+2=4)
        final int colorIndex = scoreValue + 2;

        final double size = sizes[colorIndex];
        final Color baseColor = colors[colorIndex];

        // selectedScoreValue, choice'ın puanına eşitse seçili demektir.
        final bool isSelected = _selectedScoreValue == scoreValue;

        final Color circleColor = isSelected ? baseColor : Colors.white;
        final Color borderColor = isSelected ? baseColor : Colors.grey.shade400;

        return GestureDetector(
          onTap: () {
            setState(() {
              // Seçilen dairenin puan değerini kaydet
              _selectedScoreValue = scoreValue;
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
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: baseColor.withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }

  // İLERİ Butonu
  Widget _buildNextButton() {
    // _selectedScoreValue null değilse buton aktif olur
    final bool isAnswerSelected = _selectedScoreValue != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
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
          child: InkWell(
            // Cevap seçilmişse _goToNextQuestion'ı çağır.
            onTap: isAnswerSelected ? _goToNextQuestion : null,
            borderRadius: BorderRadius.circular(30),
            child: Center(
              child: Text(
                _currentQuestionIndex < _totalQuestions - 1
                    ? "NEXT"
                    : "FINISH", // Son soru için "FINISH"
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
