// api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://mentra-app-b2ei.onrender.com';

  // Fetch analyses for a specific user or all analyses
  static Future<List<Map<String, dynamic>>> fetchAnalyses({
    String? userId,
  }) async {
    try {
      String url = '$baseUrl/analyses';
      if (userId != null) {
        url += '?user_id=$userId';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to fetch analyses: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Save analysis to PostgreSQL
  static Future<void> saveAnalysis(Map<String, dynamic> analysisData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/analyses'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(analysisData),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Failed to save analysis: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Update existing analysis
  static Future<void> updateAnalysis(
    int analysisId,
    Map<String, dynamic> updateData,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/analyses/$analysisId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(updateData),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update analysis: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Delete analysis
  static Future<void> deleteAnalysis(int analysisId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/analyses/$analysisId'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete analysis: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Health check
  static Future<Map<String, dynamic>> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Health check failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
