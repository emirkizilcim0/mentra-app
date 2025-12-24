// lib/services/diary/diary_config.dart
import 'package:http/http.dart' as http;

class DiaryConfig {
  static const String baseUrl = 'https://mentra-app-b2ei.onrender.com';
  static final http.Client client = http.Client();

  // Headers without auth (we use user_id in query params)
  static const Map<String, String> jsonHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static const Map<String, String> getHeaders = {'Accept': 'application/json'};

  // Remove getAuthHeaders method since we don't need token auth
}
