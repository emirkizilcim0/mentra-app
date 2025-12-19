// lib/services/firebase_diary/fb_diary_auth.dart
import 'package:firebase_auth/firebase_auth.dart';

class FbDiaryAuth {
  static String getUserId() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception('User not authenticated');
    }
    return uid;
  }
}
