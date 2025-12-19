// lib/utils.dart
class AppUtils {
  static String getPreview(Map<String, dynamic>? context) {
    if (context == null || context.isEmpty) return "No content available";
    final firstKey = context.keys.first;
    final content = context[firstKey] ?? "";
    return content.length > 100 ? content.substring(0, 100) + "..." : content;
  }

  static String getSampleQuestions(List<dynamic> questions) {
    if (questions.isEmpty) return "No questions available";
    String sample = "";
    for (int i = 0; i < questions.length && i < 2; i++) {
      sample += "• ${questions[i]['question']}\n";
    }
    return sample;
  }
}
