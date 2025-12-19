// lib/services/firebase_diary/fb_diary_sync_mig.dart
import 'package:mentra_app/services/dairy/dairy_service.dart';
import 'fb_diary_fetch.dart';

class FbDiarySyncMig {
  static Future<void> syncToBackend() async {
    try {
      final diaries = await FbDiaryFetch.get();
      for (final diary in diaries) {
        try {
          await DiaryService.saveDiaryEntry({
            'content': diary['content'],
            'mood': '',
            'tags': [],
          });
          print('✅ Migrated: ${diary['id']}');
        } catch (e) {
          print('❌ Failed migration ${diary['id']}: $e');
        }
      }
      print('✅ All migrated');
    } catch (e) {
      print('❌ Sync error: $e');
      rethrow;
    }
  }
}
