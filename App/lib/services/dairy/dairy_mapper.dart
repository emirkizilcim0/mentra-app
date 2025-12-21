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
    print('🗺️ Mapping analysis - item keys: ${item.keys.toList()}');

    // Debug mood specifically
    final rawMood = item['mood'];
    print('🎭 Raw mood from API: "$rawMood" (type: ${rawMood.runtimeType})');

    return {
      'id': item['id']?.toString() ?? '',
      'type': item['type'] ?? '',
      'advice': item['advice'] ?? '',
      'diaries_analyzed': item['diaries_analyzed'] ?? 0,
      'date': item['date'] ?? '',
      'formattedDate': DiaryHelpers.formatDate(item['date'] ?? ''),
      'mood': item['mood'] ?? 'Calm', // Make sure this exists
      'character_type': item['character_type'] ?? '',
      'sign': item['sign'] ?? '',
      'birth_map': item['birth_map'] ?? '',
    };
  }
}
