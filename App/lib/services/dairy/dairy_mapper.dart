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
    return {
      'id': item['id'].toString(),
      'type': item['type'],
      'advice': item['advice'],
      'diaries_analyzed': item['diaries_analyzed'],
      'date': item['date'],
      'formattedDate': DiaryHelpers.formatDate(item['date']),
      'mood': item['mood'] ?? 'Calm', // Add mood field with default
      'character_type': item['character_type'] ?? '', // Add character type
      'sign': item['sign'] ?? '', // Add zodiac sign
      'birth_map': item['birth_map'] ?? '', // Add birth map
    };
  }
}
