import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ProfileLogic {
  static String get uid => FirebaseAuth.instance.currentUser?.uid ?? "unknown";
  static final _firestore = FirebaseFirestore.instance;

  static Future<Map<String, dynamic>> loadData() async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return {};
      final data = doc.data()!;

      String birthDateStr = "";
      DateTime? selectedDate;
      if (data['birthDate'] != null) {
        selectedDate = DateTime.tryParse(data['birthDate']);
        if (selectedDate != null)
          birthDateStr = DateFormat('d MMMM yyyy').format(selectedDate);
      }

      return {
        'name': "${data['firstName'] ?? ''} ${data['lastName'] ?? ''}".trim(),
        'zodiac': data['zodiac'] ?? "",
        'birthDateStr': birthDateStr,
        'selectedDate': selectedDate,
        'mbtiTitle': data['mbtiTitle'] ?? "No result yet",
        'mbtiDesc': data['mbtiDesc'] ?? "",
        'mbtiType': data['mbtiType'] ?? "",
      };
    } catch (e) {
      return {};
    }
  }

  static Future<void> updateBirthData(DateTime date, String zodiac) async {
    await _firestore.collection('users').doc(uid).set({
      'birthDate': date.toIso8601String(),
      'zodiac': zodiac,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
