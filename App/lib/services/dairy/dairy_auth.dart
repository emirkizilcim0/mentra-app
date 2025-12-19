import 'package:firebase_auth/firebase_auth.dart';

class DiaryAuth {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Ana metod: Kullanıcı ID'sini alır
  static String getUserId() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('User not authenticated');
    }
    return uid;
  }

  // Takma ad: getRequiredId çağrıldığında getUserId'yi çalıştırır
  // Bu satır, "getRequiredId bulunamadı" hatasını çözer.
  static String getRequiredId() => getUserId();
}
