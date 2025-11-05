// result_screen.dart

import 'package:flutter/material.dart';
import '../mbti/personality_data.dart'; // Yeni oluşturulan dosya yolu

class ResultScreen extends StatelessWidget {
  final PersonalityResult result;
  final VoidCallback onRetakeTest;

  const ResultScreen({
    Key? key,
    required this.result,
    required this.onRetakeTest,
    required BorderRadius borderRadius,
    required Map<String, int> scores,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Sonucunuz'),
        backgroundColor: result.color.withOpacity(0.8), // Tipe göre renk
        automaticallyImplyLeading: false, // Geri tuşunu kaldır
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
                result.type,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.w900,
                  color: result.color,
                ),
              ),
              const SizedBox(height: 10),
              // Kişilik Tipi Adı (Örn: Kahraman)
              Text(
                result.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: result.color,
                ),
              ),
              const SizedBox(height: 30),
              // Kişilik Açıklaması
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: result.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: result.color, width: 2),
                ),
                child: Text(
                  result.description,
                  style: const TextStyle(fontSize: 18, height: 1.5),
                  textAlign: TextAlign.justify,
                ),
              ),
              const SizedBox(height: 50),
              // Testi Tekrar Çöz Butonu
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, "/home");
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Continue', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: result.color,
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
