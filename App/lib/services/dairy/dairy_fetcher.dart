// lib/services/diary/diary_fetcher.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mentra_app/services/dairy/dairy_auth.dart';
import 'package:mentra_app/services/dairy/dairy_config.dart';
import 'package:mentra_app/services/dairy/dairy_mapper.dart';

class DiaryFetcher {
  static Future<List<Map<String, dynamic>>> getAll() async {
    try {
      // Get Firebase user ID
      final userId = DiaryAuth.getUserId();
      final uri = Uri.parse('${DiaryConfig.baseUrl}/diaries/$userId?limit=50');

      final response = await DiaryConfig.client.get(
        uri,
        headers: DiaryConfig.getHeaders,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> rawList = data['diaries'];
        return rawList.map((e) => DiaryMapper.mapEntry(e)).toList();
      }
      throw Exception('Failed: ${response.statusCode} - ${response.body}');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting diaries: $e');
      }
      rethrow;
    }
  }
}
