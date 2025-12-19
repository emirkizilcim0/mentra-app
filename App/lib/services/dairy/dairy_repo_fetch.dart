// lib/services/diary/diary_repo_fetch.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mentra_app/services/dairy/dairy_auth.dart';
import 'package:mentra_app/services/dairy/dairy_config.dart';
import 'package:mentra_app/services/dairy/dairy_mapper.dart';

class DiaryRepoFetch {
  static Future<List<Map<String, dynamic>>> getAll() async {
    try {
      final uid = DiaryAuth.getUserId();
      final uri = Uri.parse('${DiaryConfig.baseUrl}/diaries/$uid?limit=50');

      final response = await http.get(uri, headers: DiaryConfig.getHeaders);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> list = data['diaries'];
        return list.map((e) => DiaryMapper.mapEntry(e)).toList();
      }
      throw Exception('Failed fetch: ${response.statusCode}');
    } catch (e) {
      print('❌ Error getting diaries: $e');
      rethrow;
    }
  }
}
