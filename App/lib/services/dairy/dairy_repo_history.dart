// lib/services/diary/diary_repo_history.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mentra_app/services/dairy/dairy_auth.dart';
import 'package:mentra_app/services/dairy/dairy_config.dart';
import 'package:mentra_app/services/dairy/dairy_mapper.dart';

class DiaryRepoHistory {
  static Future<List<Map<String, dynamic>>> getHistory({int limit = 10}) async {
    try {
      final uid = DiaryAuth.getUserId();
      final uri = Uri.parse(
        '${DiaryConfig.baseUrl}/analysis/history/$uid?limit=$limit',
      );

      final response = await http.get(uri, headers: DiaryConfig.getHeaders);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> list = data['analyses'];
        return list.map((e) => DiaryMapper.mapAnalysis(e)).toList();
      }
      throw Exception('Failed history: ${response.statusCode}');
    } catch (e) {
      print('❌ Error getting history: $e');
      rethrow;
    }
  }
}
