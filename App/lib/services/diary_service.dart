import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DiaryService {
  /// Generate a user-specific key
  static String _diaryKey() {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? "unknown";
    return 'diary_entries_$uid';
  }

  /// Get all diary entries for the current user
  static Future<List<Map<String, dynamic>>> getDiaryEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? entriesJson = prefs.getString(_diaryKey());

      if (entriesJson == null) return [];

      final List<dynamic> entriesList = jsonDecode(entriesJson);
      return entriesList.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error loading diary entries: $e');
      return [];
    }
  }

  /// Save a diary entry for the current user
  static Future<void> saveDiaryEntry(Map<String, dynamic> entry) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> existingEntries =
          await getDiaryEntries();

      existingEntries.insert(0, entry); // Add new entry at top

      final String entriesJson = jsonEncode(existingEntries);
      await prefs.setString(_diaryKey(), entriesJson);
    } catch (e) {
      print('Error saving diary entry: $e');
      rethrow;
    }
  }

  /// Delete a diary entry by ID
  static Future<void> deleteDiaryEntry(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> existingEntries =
          await getDiaryEntries();

      existingEntries.removeWhere((entry) => entry['id'] == id);

      final String entriesJson = jsonEncode(existingEntries);
      await prefs.setString(_diaryKey(), entriesJson);
    } catch (e) {
      print('Error deleting diary entry: $e');
      rethrow;
    }
  }

  /// Clear all diary entries for the current user
  static Future<void> clearAllEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_diaryKey());
    } catch (e) {
      print('Error clearing diary entries: $e');
      rethrow;
    }
  }
}
