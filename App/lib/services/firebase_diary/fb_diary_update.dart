// lib/services/firebase_diary/fb_diary_update.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'fb_diary_auth.dart';

class FbDiaryUpdate {
  static Future<void> update(String id, Map<String, dynamic> data) async {
    try {
      final uid = FbDiaryAuth.getUserId();
      final updateData = {...data, 'updatedAt': FieldValue.serverTimestamp()};

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('diaries')
          .doc(id)
          .update(updateData);

      print('✅ Diary updated in Firebase');
    } catch (e) {
      print('❌ Error updating in Firebase: $e');
      rethrow;
    }
  }
}
