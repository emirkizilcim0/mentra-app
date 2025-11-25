// result_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Diğer dosyalardan import'lar
import '../mbti/personality_data.dart'; // PersonalityResult modeli ve personalityData map'i burada
import 'services/mbti_calculator.dart'; // MbtiCalculator sınıfı burada

// ⚠️ NOT: Bu widget'a sadece ham skorları gönderiyoruz. Hesaplamayı burada yapacak.
class ResultScreen extends StatelessWidget {
  // MbtiCalculator'dan gelen ham skorlar haritası
  final Map<String, int> scores;
  final VoidCallback onRetakeTest;

  // Firestore veya navigasyon için gerekli diğer parametreleri koruyalım
  final BorderRadius borderRadius;

  const ResultScreen({
    Key? key,
    required this.scores,
    required this.onRetakeTest,
    required this.borderRadius,
  }) : super(key: key);

  // 1. Sonuç hesaplama ve veriyi alma işlemi
  PersonalityResult _calculateAndGetResult() {
    // MbtiCalculator nesnesi oluşturuluyor
    final calculator = MbtiCalculator();

    // Ham skorlar calculator'a atanıyor
    calculator.scores = scores;

    // Sonuç hesaplanıyor ve PersonalityResult nesnesi çekiliyor
    return calculator.getPersonalityResult();
  }

  // 2. Firestore'a kaydetme metodu (Daha önceki kodunuzdan korundu)
  Future<void> _saveResultToFirestore(
    BuildContext context,
    PersonalityResult result,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'mbtiTitle': result.title,
        'mbtiDesc': result.description,
        'mbtiType': result.type,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Kayıttan sonra ana sayfaya yönlendirme
      Navigator.pushNamed(context, "/home");
    } catch (e) {
      print("Error saving MBTI result: $e");
      Navigator.pushNamed(context, "/home");
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🎉 EKRAN İÇİNDE HESAPLAMA YAPILIYOR
    final PersonalityResult finalResult = _calculateAndGetResult();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Sonucunuz'),
        backgroundColor: finalResult.color.withOpacity(0.8),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Kişilik Tipi Kodu (Örn: ENFJ)
              Text(
                finalResult.type, // <-- personality_data.dart'tan gelen TIP
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.w900,
                  color: finalResult.color,
                ),
              ),
              const SizedBox(height: 10),
              // Kişilik Tipi Adı (Örn: Kahraman)
              Text(
                finalResult.title, // <-- personality_data.dart'tan gelen BAŞLIK
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: finalResult.color,
                ),
              ),
              const SizedBox(height: 30),
              // Kişilik Açıklaması (ANLAMI)
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: finalResult.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: finalResult.color, width: 2),
                ),
                child: Text(
                  finalResult
                      .description, // <-- personality_data.dart'tan gelen AÇIKLAMA
                  style: const TextStyle(fontSize: 18, height: 1.5),
                  textAlign: TextAlign.justify,
                ),
              ),
              const SizedBox(height: 50),
              // Continue Button
              ElevatedButton.icon(
                onPressed: () => _saveResultToFirestore(context, finalResult),
                icon: const Icon(Icons.check),
                label: const Text('Continue', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: finalResult.color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
