import 'package:http/http.dart' as http;

// lib/services/diary/diary_config.dart
class DiaryConfig {
  static const String baseUrl = 'https://mentra-app-b2ei.onrender.com';

  static const Map<String, String> jsonHeaders = {
    'Content-Type': 'application/json',
  };

  static const Map<String, String> getHeaders = {'Accept': 'application/json'};
  static final http.Client client = http.Client();
}
