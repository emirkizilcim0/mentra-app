import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mentra_app/services/dairy/dairy_service.dart';

class LogicData {
  static Future<Map<String, String>> loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return {};
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (!doc.exists) return {};
      final data = doc.data()!;
      return {
        'name': "${data['firstName'] ?? ''} ${data['lastName'] ?? ''}".trim(),
        'sign': data['zodiac'] ?? '',
        'type': data['mbtiType'] ?? '',
      };
    } catch (e) {
      return {};
    }
  }

  static Future<List<Map<String, dynamic>>> loadDiaries() async {
    try {
      return await DiaryService.getDiaryEntries();
    } catch (e) {
      throw Exception('Failed to load diaries');
    }
  }
}
