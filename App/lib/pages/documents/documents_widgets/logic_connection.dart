// lib/logic_connection.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'constants.dart';

class ConnectionLogic {
  static Future<String> test() async {
    try {
      final response = await http.get(Uri.parse(AppConstants.baseUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return "✅ Backend Connected!\n\n"
            "Message: ${data['message']}\n"
            "Status: ${data['status']}";
      }
      return "❌ Backend Error: ${response.statusCode}";
    } catch (e) {
      return "❌ Cannot reach backend: $e";
    }
  }
}
