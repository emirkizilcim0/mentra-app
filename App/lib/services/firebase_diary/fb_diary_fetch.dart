// lib/services/firebase_diary/fb_diary_fetch.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'fb_diary_auth.dart';

class FbDiaryFetch {
  static Future<List<Map<String, dynamic>>> get() async {
    try {
      final uid = FbDiaryAuth.getUserId();
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('diaries')
          .orderBy('createdAt', descending: true)
          .get();

      return snap.docs.map((doc) {
        final d = doc.data();
        return {
          'id': doc.id,
          'title': d['title'],
          'content': d['content'],
          'date': (d['date'] as Timestamp).toDate().toIso8601String(),
          'formattedDate': d['formattedDate'],
          'userId': d['userId'],
          'createdAt': d['createdAt']?.toDate().toIso8601String(),
        };
      }).toList();
    } catch (e) {
      print('❌ Error fetching from Firebase: $e');
      rethrow;
    }
  }
}
