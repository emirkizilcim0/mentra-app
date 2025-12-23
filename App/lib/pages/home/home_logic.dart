// lib/pages/home/home_logic.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomeLogic {
  static Future<String> sendToBackend() async {
    const backendUrl = "https://mentra-app-b2ei.onrender.com";
    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': 'Mentra User'}),
      );

      final data = jsonDecode(response.body);
      return data["message"] ?? "No message received";
    } catch (e) {
      return "Error: $e";
    }
  }
}
