// lib/advice_utils.dart
class AdviceUtils {
  static String getDate(Map<String, dynamic> item) {
    return item['formattedDate'] ?? item['date'] ?? '';
  }

  static String getAdvice(Map<String, dynamic> item) {
    return item['advice'] ?? '';
  }
}
