// dairy_auth.dart
import 'package:firebase_auth/firebase_auth.dart';

class DiaryAuth {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get Firebase user ID
  static String getUserId() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('User not authenticated');
    }
    return uid;
  }

  // Alias for getUserId
  static String getRequiredId() => getUserId();

  // Optional: Get token if needed for future JWT auth
  static Future<String?> getToken() async {
    try {
      return await _auth.currentUser?.getIdToken();
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }
}
