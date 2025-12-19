// lib/services/firebase_diary_service.dart

import 'package:mentra_app/services/firebase_diary/fb_diary_add.dart';
import 'package:mentra_app/services/firebase_diary/fb_diary_check.dart';
import 'package:mentra_app/services/firebase_diary/fb_diary_cleanup.dart';
import 'package:mentra_app/services/firebase_diary/fb_diary_sync_mig.dart';
import 'package:mentra_app/services/firebase_diary/fb_diary_update.dart';

import 'fb_diary_delete.dart';
import 'fb_diary_fetch.dart';

class FirebaseDiaryService {
  static Future<void> addDiaryToFirebase(Map<String, dynamic> entry) =>
      FbDiaryAdd.add(entry);

  static Future<List<Map<String, dynamic>>> getDiariesFromFirebase() =>
      FbDiaryFetch.get();

  static Future<void> deleteDiaryFromFirebase(String id) =>
      FbDiaryDelete.delete(id);

  static Future<void> updateDiaryInFirebase(
    String id,
    Map<String, dynamic> data,
  ) => FbDiaryUpdate.update(id, data);

  static Future<void> syncFirebaseToBackend() => FbDiarySyncMig.syncToBackend();

  static Future<bool> hasFirebaseData() => FbDiaryCheck.hasData();

  static Future<void> cleanupFirebaseData() => FbDiaryCleanup.cleanup();

  // --- EKLENEN KISIM BAŞLANGIÇ ---
  // Test dosyasının (flutter_test) beklediği method:
  static Future<void> clearAllEntries() => FbDiaryCleanup.cleanup();
  // --- EKLENEN KISIM BİTİŞ ---

  static Future<void> syncLocalDiariesToFirebase() async {
    print('⚠️ Deprecated: using FastAPI backend');
  }
}
