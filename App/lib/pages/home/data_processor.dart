import 'package:intl/intl.dart';
import 'sentiment_utils.dart';

class DataProcessor {
  static Map<String, int> processAnalyses(List<dynamic> analyses) {
    final Map<String, int> percents = {};
    for (var analysis in analyses) {
      try {
        final date = DateTime.parse(analysis['date']);
        final key = DateFormat('yyyy-MM-dd').format(date);
        final advice = (analysis['advice'] ?? '') as String;
        percents[key] = estimateHappinessPercent(advice);
      } catch (_) {}
    }
    return percents;
  }

  static Map<String, String> processEntries(
    List<dynamic> entries,
    Map<String, int> percents,
  ) {
    final Map<String, String> days = {};
    for (var entry in entries) {
      final date = DateTime.parse(entry['date'] as String);
      final key = DateFormat('yyyy-MM-dd').format(date);
      days[key] = percents.containsKey(key) ? 'advised' : 'written';
    }
    return days;
  }
}
