// lib/services/diary/diary_repo_update.dart
import 'package:http/http.dart' as DiaryRepoDelete;
import 'package:mentra_app/services/dairy/dairy_repo_save.dart';

class DiaryRepoUpdate {
  static Future<Map<String, dynamic>> update(
    String diaryId,
    Map<String, dynamic> updates,
  ) async {
    try {
      // Not: Backend update endpoint'i olmadığı için önce silip sonra ekliyoruz
      await DiaryRepoDelete.delete(diaryId as Uri);
      final newEntry = await DiaryRepoSave.save(updates);
      return newEntry;
    } catch (e) {
      print('❌ Error updating diary entry: $e');
      rethrow;
    }
  }
}
