import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'https://mentra-app.onrender.com'; // Your Render URL

  static Future<AnalysisResult> analyzeName(
    String name, {
    String? userId,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/analyze'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'name': name,
          'user_id': userId,
          'additional_data': additionalData,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AnalysisResult.fromJson(data);
      } else if (response.statusCode == 429) {
        throw Exception('Rate limit exceeded. Please try again later.');
      } else {
        throw Exception('Failed to analyze: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<HealthStatus> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {'Accept': 'application/json'},
      );

      return HealthStatus.fromJson(json.decode(response.body));
    } catch (e) {
      throw Exception('Health check failed: $e');
    }
  }
}

class AnalysisResult {
  final String message;
  final String status;
  final int score;
  final int? analysisId;

  AnalysisResult({
    required this.message,
    required this.status,
    required this.score,
    this.analysisId,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      message: json['message'],
      status: json['status'],
      score: json['score'],
      analysisId: json['analysis_id'],
    );
  }
}

class HealthStatus {
  final String status;
  final String database;

  HealthStatus({required this.status, required this.database});

  factory HealthStatus.fromJson(Map<String, dynamic> json) {
    return HealthStatus(status: json['status'], database: json['database']);
  }
}
