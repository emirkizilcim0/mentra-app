import 'package:mentra_app/mbti/personality_data.dart';

class MbtiCalculator {
  Map<String, int> scores = {
    'E': 0,
    'I': 0,
    'S': 0,
    'N': 0,
    'T': 0,
    'F': 0,
    'J': 0,
    'P': 0,
  };

  void addScore(String scoreType, int value) {
    String oppositeType = _getOpposite(scoreType);

    if (value > 0) {
      scores[scoreType] = (scores[scoreType] ?? 0) + value;
    } else if (value < 0) {
      scores[oppositeType] = (scores[oppositeType] ?? 0) + value.abs();
    }
    print("DEBUG: $scoreType tipine $value eklendi. Güncel: $scores");
  }

  String _getOpposite(String type) {
    if (type == 'E') return 'I';
    if (type == 'S') return 'N';
    if (type == 'T') return 'F';
    if (type == 'J') return 'P';
    return '';
  }

  String calculateResult() {
    String result = '';
    // Puanlar eşitse (0-0 veya 5-5) MBTI standardı gereği ilk harf seçilir
    result += (scores['E']! >= scores['I']!) ? 'E' : 'I';
    result += (scores['S']! >= scores['N']!) ? 'S' : 'N';
    result += (scores['T']! >= scores['F']!) ? 'T' : 'F';
    result += (scores['J']! >= scores['P']!) ? 'J' : 'P';
    return result;
  }

  void reset() {
    scores = {'E': 0, 'I': 0, 'S': 0, 'N': 0, 'T': 0, 'F': 0, 'J': 0, 'P': 0};
  }

  PersonalityResult getPersonalityResult() {
    String mbtiType = calculateResult();
    return personalityData[mbtiType] ?? personalityData['INTJ']!;
  }
}
