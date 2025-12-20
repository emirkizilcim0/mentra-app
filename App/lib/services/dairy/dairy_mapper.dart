// lib/services/diary/diary_mapper.dart
import 'package:mentra_app/pages/dairy/detail/dairy_helpers.dart';

class DiaryMapper {
  static Map<String, dynamic> mapEntry(dynamic item) {
    return {
      'id': item['id'].toString(),
      'title': DiaryHelpers.generateTitle(item['content']),
      'content': item['content'],
      'date': item['date'],
      'formattedDate': DiaryHelpers.formatDate(item['date']),
      'mood': item['mood'] ?? '',
      'tags': List<String>.from(item['tags'] ?? []),
    };
  }

  static Map<String, dynamic> mapAnalysis(dynamic item) {
    // Debug the raw item
    print('🗺️ Mapping analysis - raw item keys: ${item.keys.toList()}');

    // Get mood from various possible field names
    String mood =
        item['mood']?.toString() ??
        item['mood_label']?.toString() ??
        item['emotion']?.toString() ??
        '';

    print('🗺️ Raw mood value found: "$mood"');

    return {
      'id': item['id']?.toString() ?? '',
      'type': item['type'],
      'advice': item['advice'] ?? '',
      'diaries_analyzed': item['diaries_analyzed'] ?? 0,
      'date': item['analysis_date'] ?? item['date'] ?? item['created_at'] ?? '',
      'formattedDate': null, // Will be set later
      'mood': mood.isNotEmpty ? mood : 'Calm', // Don't default to Calm if empty
      'character_type': item['character_type'] ?? '',
      'sign': item['sign'] ?? '',
      'birth_map': item['birth_map'] ?? '',
    };
  }
}
