// lib/services/dairy/dairy_repo_analyze.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mentra_app/services/dairy/dairy_auth.dart';
import 'package:mentra_app/services/dairy/dairy_config.dart';

class DiaryRepoAnalyze {
  static Future<Map<String, dynamic>> analyze({
    required String cType,
    required String sign,
    required String bMap,
    int count = 10,
    String? content, // Tekil içerik geliyor
    List<String>? diaryIds,
  }) async {
    try {
      final uid = DiaryAuth.getUserId();

      final Map<String, dynamic> requestData = {
        'user_id': uid,
        'character_type': cType,
        'sign': sign,
        'birth_map': bMap,
        'diary_count': count,
      };

      // --- HATA ÇÖZÜMÜ BURADA ---
      // Python kodu 'diaries' adında bir LİSTE bekliyor.
      // Bizdeki tekil 'content' stringini bir listenin içine koyup gönderiyoruz.
      if (content != null && content.isNotEmpty) {
        requestData['diaries'] = [content]; // Örn: ["Bugün çok mutluyum..."]
      }
      // Eğer içerik yoksa ama ID varsa, belki backend ID'den çekip listeye koyuyordur
      else if (diaryIds != null && diaryIds.isNotEmpty) {
        requestData['diary_ids'] = diaryIds;
      }

      // Konsola kontrol çıktısı
      print("📤 BACKEND'E GİDEN VERİ: $requestData");

      final body = json.encode(requestData);

      final response = await http.post(
        Uri.parse('${DiaryConfig.baseUrl}/analyze/diaries'),
        headers: DiaryConfig.jsonHeaders,
        body: body,
      );

      if (response.statusCode == 200) {
        print("✅ Analiz Başarılı: ${response.body}");
        return json.decode(response.body);
      }

      throw Exception('Failed analyze: ${response.statusCode}');
    } catch (e) {
      print('❌ Error analyzing: $e');
      rethrow;
    }
  }
}
