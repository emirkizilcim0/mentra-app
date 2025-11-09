import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DiaryService {
  static const String _diaryKey = 'diary_entries';

  static Future<List<Map<String, dynamic>>> getDiaryEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? entriesJson = prefs.getString(_diaryKey);
      
      if (entriesJson == null) {
        return [];
      }

      final List<dynamic> entriesList = jsonDecode(entriesJson);
      return entriesList.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error loading diary entries: $e');
      return [];
    }
  }

  static Future<void> saveDiaryEntry(Map<String, dynamic> entry) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> existingEntries = await getDiaryEntries();
      
      existingEntries.insert(0, entry);
      
      final String entriesJson = jsonEncode(existingEntries);
      await prefs.setString(_diaryKey, entriesJson);
    } catch (e) {
      print('Error saving diary entry: $e');
      rethrow;
    }
  }

  static Future<void> deleteDiaryEntry(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> existingEntries = await getDiaryEntries();
      
      existingEntries.removeWhere((entry) => entry['id'] == id);
      
      final String entriesJson = jsonEncode(existingEntries);
      await prefs.setString(_diaryKey, entriesJson);
    } catch (e) {
      print('Error deleting diary entry: $e');
      rethrow;
    }
  }

  static Future<void> clearAllEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_diaryKey);
    } catch (e) {
      print('Error clearing diary entries: $e');
      rethrow;
    }
  }
}