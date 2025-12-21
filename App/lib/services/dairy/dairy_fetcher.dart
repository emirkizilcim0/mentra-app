// lib/services/diary/diary_fetcher.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mentra_app/services/dairy/dairy_auth.dart';
import 'package:mentra_app/services/dairy/dairy_config.dart';
import 'package:mentra_app/services/dairy/dairy_mapper.dart';

class DiaryFetcher {
  static Future<List<Map<String, dynamic>>> getAll() async {
    try {
      final uid = DiaryAuth.getRequiredId();
      final uri = Uri.parse('${DiaryConfig.baseUrl}/diaries/$uid?limit=50');

      final response = await DiaryConfig.client.get(uri, headers: DiaryConfig.getHeaders);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> rawList = data['diaries'];

        // DÜZELTME: mapList yerine, listeyi .map ile dönüp tek tek mapEntry çağırıyoruz
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
