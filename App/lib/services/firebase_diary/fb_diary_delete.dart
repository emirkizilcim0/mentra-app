// lib/services/firebase_diary/fb_diary_delete.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'fb_diary_auth.dart';

class FbDiaryDelete {
  static Future<void> delete(String diaryId) async {
    try {
      final uid = FbDiaryAuth.getUserId();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('diaries')
          .doc(diaryId)
          .delete();

      print('✅ Diary deleted from Firebase');
    } catch (e) {
      print('❌ Error deleting from Firebase: $e');
      rethrow;
    }
  }
}
