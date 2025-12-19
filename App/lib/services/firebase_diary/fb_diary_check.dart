// lib/services/firebase_diary/fb_diary_check.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FbDiaryCheck {
  static Future<bool> hasData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return false;

      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('diaries')
          .limit(1)
          .get();

      return snap.docs.isNotEmpty;
    } catch (e) {
      print('❌ Check error: $e');
      return false;
    }
  }
}
