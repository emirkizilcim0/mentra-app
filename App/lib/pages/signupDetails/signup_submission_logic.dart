import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mentra_app/services/auth/auth_service.dart';

import 'package:mentra_app/services/dairy/dairy_auth.dart';
import 'package:mentra_app/pages/signupDetails/zodiac_calculator.dart'; // Eğer ayrı dosyadaysa
// Veya ZodiacCalculator'ı buraya dahil edebilirsin:
// import 'package:mentra_app/pages/signup/signup_details_page.dart'; (Eğer orada tanımlıysa)

class SignupSubmissionLogic {
  static Future<bool> signUpAndSaveData(
    String email,
    String pass,
    String first,
    String last,
    DateTime bd,
  ) async {
    try {
      final user = await AuthService().signUpWithEmail(email, pass);
      if (user == null) return false;

      // Basit bir Zodiac hesaplama (Eğer import sorunu yaşarsan burayı kullanabilirsin)
      String getZodiac(DateTime d) {
        // ... burç hesaplama kodu ...
        // Şimdilik ZodiacCalculator.getZodiac(bd) kullandığını varsayıyorum.
        return "Aries"; // Geçici, import düzgünse ZodiacCalculator.getZodiac(bd) kullan.
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'firstName': first,
        'lastName': last,
        'birthDate': bd.toIso8601String(),
        // 'zodiac': ZodiacCalculator.getZodiac(bd), // Import hatası alırsan burayı kontrol et
        'zodiac': "Unknown", // Geçici
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'mbtiTitle': "No result yet",
        'mbtiDesc': "",
      });
      return true;
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }
}
