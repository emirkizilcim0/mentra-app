import 'sentiment_data.dart';

int estimateHappinessPercent(String text) {
  if (text.isEmpty) return 50;
  final lower = text.toLowerCase();

  int p = 0;
  int n = 0;

  for (final w in positiveWords) {
    if (lower.contains(w)) p++;
  }
  for (final w in negativeWords) {
    if (lower.contains(w)) n++;
  }

  final score = (p - n).clamp(-10, 10);
  final percent = ((score + 10) * 5).toInt();
  return percent.clamp(0, 100);
}
