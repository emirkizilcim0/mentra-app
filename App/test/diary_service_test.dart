import 'package:flutter_test/flutter_test.dart';
import 'package:mentra_app/services/diary_service.dart';

void main() {
  group('DiaryService Tests', () {
    test('should save and retrieve diary entries', () async {
      // Clear any existing entries first
      await DiaryService.clearAllEntries();
      
      // Create a test diary entry
      final testEntry = {
        'id': 'test123',
        'title': 'Test Diary',
        'content': 'This is a test diary entry',
        'date': '2024-01-01T12:00:00.000Z',
        'formattedDate': '01 January 2024, 12:00',
      };
      
      // Save the entry
      await DiaryService.saveDiaryEntry(testEntry);
      
      // Retrieve entries
      final entries = await DiaryService.getDiaryEntries();
      
      // Verify
      expect(entries.length, 1);
      expect(entries[0]['title'], 'Test Diary');
      expect(entries[0]['content'], 'This is a test diary entry');
    });
    
    test('should delete diary entry', () async {
      // Clear any existing entries first
      await DiaryService.clearAllEntries();
      
      // Create and save a test entry
      final testEntry = {
        'id': 'delete123',
        'title': 'Entry to Delete',
        'content': 'This entry will be deleted',
        'date': '2024-01-02T12:00:00.000Z',
        'formattedDate': '02 January 2024, 12:00',
      };
      
      await DiaryService.saveDiaryEntry(testEntry);
      
      // Delete the entry
      await DiaryService.deleteDiaryEntry('delete123');
      
      // Verify deletion
      final entries = await DiaryService.getDiaryEntries();
      expect(entries.length, 0);
    });
  });
}