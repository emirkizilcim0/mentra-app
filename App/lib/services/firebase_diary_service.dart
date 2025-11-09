import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'diary_service.dart';

class FirebaseDiaryService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Kullanıcı ID'sini al
  static String? get _userId => _auth.currentUser?.uid;

  // Firebase'e günlük ekleme
  static Future<void> addDiaryToFirebase(Map<String, dynamic> diaryEntry) async {
    try {
      if (_userId == null) {
        throw Exception('User not authenticated');
      }

      final diaryData = {
        'title': diaryEntry['title'],
        'content': diaryEntry['content'],
        'date': Timestamp.fromDate(DateTime.parse(diaryEntry['date'])),
        'formattedDate': diaryEntry['formattedDate'],
        'userId': _userId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('diaries')
          .doc(diaryEntry['id'])
          .set(diaryData);

      print('✅ Diary added to Firebase successfully');
    } catch (e) {
      print('❌ Error adding diary to Firebase: $e');
      rethrow;
    }
  }

  // Firebase'den günlükleri çekme
  static Future<List<Map<String, dynamic>>> getDiariesFromFirebase() async {
    try {
      if (_userId == null) {
        throw Exception('User not authenticated');
      }

      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('diaries')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'title': data['title'],
          'content': data['content'],
          'date': (data['date'] as Timestamp).toDate().toIso8601String(),
          'formattedDate': data['formattedDate'],
          'userId': data['userId'],
          'createdAt': data['createdAt']?.toDate().toIso8601String(),
        };
      }).toList();
    } catch (e) {
      print('❌ Error getting diaries from Firebase: $e');
      rethrow;
    }
  }

  // Firebase'den günlük silme
  static Future<void> deleteDiaryFromFirebase(String diaryId) async {
    try {
      if (_userId == null) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('diaries')
          .doc(diaryId)
          .delete();

      print('✅ Diary deleted from Firebase successfully');
    } catch (e) {
      print('❌ Error deleting diary from Firebase: $e');
      rethrow;
    }
  }

  // Firebase'de günlük güncelleme
  static Future<void> updateDiaryInFirebase(
      String diaryId, Map<String, dynamic> updatedData) async {
    try {
      if (_userId == null) {
        throw Exception('User not authenticated');
      }

      final updateData = {
        ...updatedData,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('diaries')
          .doc(diaryId)
          .update(updateData);

      print('✅ Diary updated in Firebase successfully');
    } catch (e) {
      print('❌ Error updating diary in Firebase: $e');
      rethrow;
    }
  }

  // Tüm günlükleri senkronize etme (yerel -> firebase)
  static Future<void> syncLocalDiariesToFirebase() async {
    try {
      final localDiaries = await DiaryService.getDiaryEntries();
      
      for (final diary in localDiaries) {
        await addDiaryToFirebase(diary);
      }
      
      print('✅ All local diaries synced to Firebase');
    } catch (e) {
      print('❌ Error syncing diaries to Firebase: $e');
      rethrow;
    }
  }

  // Firebase'den yerel depolamaya senkronizasyon
  static Future<void> syncFirebaseDiariesToLocal() async {
    try {
      final firebaseDiaries = await getDiariesFromFirebase();
      
      // Yerel depolamayı temizle
      await DiaryService.clearAllEntries();
      
      // Firebase'den gelen verileri yerel depolamaya kaydet
      for (final diary in firebaseDiaries) {
        await DiaryService.saveDiaryEntry(diary);
      }
      
      print('✅ All Firebase diaries synced to local');
    } catch (e) {
      print('❌ Error syncing diaries from Firebase: $e');
      rethrow;
    }
  }
}