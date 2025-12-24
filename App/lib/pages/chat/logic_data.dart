import 'package:mentra_app/services/dairy/dairy_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LogicData {
  static Future<Map<String, dynamic>> loadUserData() async {
    try {
      print('🔍 LogicData.loadUserData() - Getting current user...');

      // FIRST: Try the new /user/current endpoint
      try {
        print('🔄 Trying /user/current endpoint...');
        final response = await http.get(
          Uri.parse('https://mentra-app-b2ei.onrender.com/user/current'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );

        print('📡 /user/current response status: ${response.statusCode}');

        if (response.statusCode == 200) {
          final userData = json.decode(response.body);
          print('✅ Got user data from /user/current: ${userData['user_id']}');
          print('📊 User data: ${userData.keys.toList()}');

          // Ensure all required fields exist
          return {
            'id': userData['id'] ?? userData['user_id'] ?? 'unknown',
            'user_id': userData['user_id'] ?? userData['id'] ?? 'unknown',
            'name': userData['name'] ?? 'User',
            'type': userData['type'] ?? 'User',
            'sign': userData['sign'] ?? 'Unknown',
            'birth_map': userData['birth_map'] ?? 'Unknown',
            'character_type': userData['character_type'] ?? 'User',
            'exists': userData['exists'] ?? false,
            'created_at':
                userData['created_at'] ?? DateTime.now().toIso8601String(),
            // Include any other fields from the response
            ...userData,
          };
        } else {
          print(
            '⚠️ /user/current returned ${response.statusCode}: ${response.body}',
          );
        }
      } catch (e) {
        print('⚠️ /user/current endpoint error: $e');
      }

      // SECOND: Try to get user from existing analyses (fallback)
      try {
        print('🔄 Falling back to checking existing analyses...');
        final response = await http.get(
          Uri.parse('https://mentra-app-b2ei.onrender.com/analyses?limit=1'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          print('📊 Analyses endpoint returned ${data.length} items');

          if (data.isNotEmpty) {
            final firstAnalysis = data[0];
            final userId = firstAnalysis['user_id']?.toString();
            if (userId != null && userId.isNotEmpty && userId != 'unknown') {
              print('✅ Found user ID in analyses: $userId');
              return {
                'id': userId,
                'user_id': userId,
                'name': 'User',
                'type': 'User',
                'sign': firstAnalysis['sign'] ?? 'Unknown',
                'character_type': firstAnalysis['character_type'] ?? 'User',
                'birth_map': 'Unknown',
                'exists': true,
                'created_at': DateTime.now().toIso8601String(),
              };
            }
          }
        }
      } catch (e) {
        print('⚠️ Could not get user from analyses endpoint: $e');
      }

      // THIRD: Try to create a default user via diaries endpoint
      print('🔄 Creating default user via diaries/save...');
      try {
        final uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
        final newUserId = 'user_$uniqueId';

        final saveResponse = await http.post(
          Uri.parse(
            'https://mentra-app-b2ei.onrender.com/diaries/save?user_id=$newUserId',
          ),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'content': 'Welcome to Mentra!',
            'mood': 'Calm',
            'tags': ['welcome'],
          }),
        );

        if (saveResponse.statusCode == 200) {
          print('✅ Created new user with ID: $newUserId');
          return {
            'id': newUserId,
            'user_id': newUserId,
            'name': 'New User',
            'type': 'User',
            'sign': 'Unknown',
            'birth_map': 'Unknown',
            'character_type': 'User',
            'exists': false,
            'created_at': DateTime.now().toIso8601String(),
          };
        }
      } catch (e) {
        print('⚠️ Could not create new user: $e');
      }

      // FINAL FALLBACK: Use hardcoded default
      print('⚠️ Using hardcoded default user');
      const defaultUserId = 'default_user';
      return {
        'id': defaultUserId,
        'user_id': defaultUserId,
        'name': 'User',
        'type': 'User',
        'sign': 'Unknown',
        'birth_map': 'Unknown',
        'character_type': 'User',
        'exists': false,
        'created_at': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('❌ Error in LogicData.loadUserData(): $e');
      return {
        'id': 'unknown',
        'user_id': 'unknown',
        'name': 'User',
        'type': 'User',
        'sign': 'Unknown',
        'birth_map': 'Unknown',
        'character_type': 'User',
        'exists': false,
        'created_at': DateTime.now().toIso8601String(),
      };
    }
  }

  static Future<List<Map<String, dynamic>>> loadDiaries() async {
    try {
      // Get user data first to get the user ID
      final userData = await loadUserData();
      final userId = userData['id']?.toString() ?? 'unknown';

      print('📋 Loading diaries for user: $userId');

      if (userId == 'unknown') {
        print('⚠️ Cannot load diaries without user ID');
        return [];
      }

      final response = await http.get(
        Uri.parse(
          'https://mentra-app-b2ei.onrender.com/diaries/$userId?limit=20',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['diaries'] ?? []);
      } else {
        print('❌ Error loading diaries: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error loading diaries: $e');
      return [];
    }
  }
}
