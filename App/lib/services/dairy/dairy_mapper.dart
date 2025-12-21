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

  static Map<String, dynamic> mapAnalysis(dynamic data) {
    if (data is! Map) return {};

    return {
      'id': data['id']?.toString() ?? '',
      'advice': data['advice'] ?? data['advice_text'] ?? '',
      'analysis':
          data['advice'] ??
          data['advice_text'] ??
          data['analysis'] ??
          '', // CRITICAL
      'mood': data['mood'] ?? 'Calm',
      'character_type':
          data['character_type'] ??
          data['analysis_data']?['character_type'] ??
          'Unknown',
      'sign': data['sign'] ?? data['analysis_data']?['sign'] ?? 'Unknown',
      'birth_map':
          data['birth_map'] ??
          data['analysis_data']?['birth_map'] ??
          'Not specified',
      'date':
          data['date'] ??
          data['created_at']?.toString() ??
          DateTime.now().toString(),
      'analysis_date':
          data['analysis_date'] ??
          data['created_at']?.toString() ??
          DateTime.now().toString(),
      'created_at': data['created_at']?.toString() ?? DateTime.now().toString(),
      'diaries_analyzed': data['diaries_analyzed'] ?? 1,
    };
  }
}
