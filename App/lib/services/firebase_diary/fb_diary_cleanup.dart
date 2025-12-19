// lib/services/firebase_diary/fb_diary_cleanup.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'fb_diary_auth.dart';

class FbDiaryCleanup {
  static Future<void> cleanup() async {
    try {
      final uid = FbDiaryAuth.getUserId();
      final ref = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('diaries');

      final snapshot = await ref.get();
      final batch = FirebaseFirestore.instance.batch();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('✅ Firebase data cleaned');
    } catch (e) {
      print('❌ Cleanup error: $e');
      rethrow;
    }
  }
}
