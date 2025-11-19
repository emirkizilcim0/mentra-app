// result_screen.dart

import 'package:flutter/material.dart';
import '../mbti/personality_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ResultScreen extends StatelessWidget {
  final PersonalityResult result;
  final VoidCallback onRetakeTest;
  final BorderRadius borderRadius;
  final Map<String, int> scores;

  const ResultScreen({
    Key? key,
    required this.result,
    required this.onRetakeTest,
    required this.borderRadius,
    required this.scores,
  }) : super(key: key);

  Future<void> _saveResultToFirestore(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'mbtiTitle': result.title,
        'mbtiDesc': result.description,
        'mbtiType': result.type,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Navigate to home page after saving
      Navigator.pushNamed(context, "/home");
    } catch (e) {
      print("Error saving MBTI result: $e");
      // Still navigate even if there's an error
      Navigator.pushNamed(context, "/home");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Sonucunuz'),
        backgroundColor: result.color.withOpacity(0.8),
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
              // Continue Button
              ElevatedButton.icon(
                onPressed: () => _saveResultToFirestore(context),
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
