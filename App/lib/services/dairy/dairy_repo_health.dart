// lib/services/diary/diary_repo_health.dart
import 'package:flutter/foundation.dart';
import 'package:mentra_app/services/dairy/dairy_config.dart';

class DiaryRepoHealth {
  static Future<bool> check() async {
    try {
      final response = await DiaryConfig.client.get(
        Uri.parse('${DiaryConfig.baseUrl}/'),
        headers: DiaryConfig.getHeaders,
      );
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Backend health check failed: $e');
      }
      return false;
    }
  }
}
