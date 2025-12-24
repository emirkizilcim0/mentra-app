// lib/services/user_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService {
  static String? _currentUserId;
  static Map<String, dynamic>? _currentUserData;

  // Get current user ID
  static Future<String> getCurrentUserId() async {
    // If we already have it cached, return it
    if (_currentUserId != null && _currentUserId!.isNotEmpty) {
      return _currentUserId!;
    }

    try {
      print('🔍 Fetching current user from backend...');

      // Call your backend to get current user info
      final response = await http.get(
        Uri.parse('https://mentra-app-b2ei.onrender.com/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        print('✅ User data received: ${userData.keys.toList()}');

        // Try different possible user ID fields
        String? userId;

        if (userData['id'] != null) {
          userId = userData['id'].toString();
        } else if (userData['user_id'] != null) {
          userId = userData['user_id'].toString();
        } else if (userData['_id'] != null) {
          userId = userData['_id'].toString();
        } else if (userData['uid'] != null) {
          userId = userData['uid'].toString();
        }

        if (userId != null && userId.isNotEmpty) {
          _currentUserId = userId;
          _currentUserData = userData;
          print('✅ Current user ID: $userId');
          return userId;
        }
      }

      print('⚠️ Could not get user ID from API');
      return 'unknown';
    } catch (e) {
      print('❌ Error getting user ID: $e');
      return 'unknown';
    }
  }

  // Get full user data
  static Future<Map<String, dynamic>> getCurrentUserData() async {
    if (_currentUserData != null) {
      return _currentUserData!;
    }

    // If we don't have user data, get it
    await getCurrentUserId();
    return _currentUserData ??
        {
          'id': _currentUserId ?? 'unknown',
          'name': 'User',
          'type': 'User',
          'sign': 'Unknown',
        };
  }

  // Clear cached user data (for logout)
  static void clearUserData() {
    _currentUserId = null;
    _currentUserData = null;
  }
}
