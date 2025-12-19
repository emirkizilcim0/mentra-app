// lib/services/firebase_diary/fb_diary_add.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'fb_diary_auth.dart';

class FbDiaryAdd {
  static Future<void> add(Map<String, dynamic> entry) async {
    try {
      final uid = FbDiaryAuth.getUserId();
      final data = {
        'title': entry['title'],
        'content': entry['content'],
        'date': Timestamp.fromDate(DateTime.parse(entry['date'])),
        'formattedDate': entry['formattedDate'],
        'userId': uid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('diaries')
          .doc(entry['id'])
          .set(data);

      print('✅ Diary added to Firebase');
    } catch (e) {
      print('❌ Error adding to Firebase: $e');
      rethrow;
    }
  }
}
