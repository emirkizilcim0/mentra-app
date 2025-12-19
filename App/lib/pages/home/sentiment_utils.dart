int estimateHappinessPercent(String text) {
  if (text.isEmpty) return 50;
  final lower = text.toLowerCase();

  final positives = [
    'happy',
    'joy',
    'great',
    'good',
    'love',
    'wonderful',
    'optimistic',
    'positive',
    'success',
    'calm',
    'peace',
    'glad',
    'smile',
  ];
  final negatives = [
    'sad',
    'anxious',
    'worry',
    'stress',
    'angry',
    'bad',
    'pain',
    'cry',
    'depress',
    'fear',
    'lonely',
    'tired',
    'hopeless',
  ];

  int p = 0;
  int n = 0;

  for (final w in positives) {
    if (lower.contains(w)) p++;
  }
  for (final w in negatives) {
    if (lower.contains(w)) n++;
  }

  final score = (p - n).clamp(-10, 10);
  return ((score + 10) * 5).toInt().clamp(0, 100);
}
