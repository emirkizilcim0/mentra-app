String getEmojiFor(int percent) {
  if (percent >= 75) return '😄';
  if (percent >= 50) return '😐';
  if (percent >= 25) return '😕';
  return '😭';
}

String getTitleFromAdvice(String advice) {
  final text = advice.trim();
  if (text.isEmpty) return 'Advice';

  final dot = text.indexOf('.');
  final first = dot > 0 ? text.substring(0, dot) : text.split('\n').first;

  return first.length <= 60 ? first : '${first.substring(0, 60)}...';
}
