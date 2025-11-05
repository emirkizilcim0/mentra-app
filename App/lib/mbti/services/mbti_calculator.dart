import 'package:mentra_app/mbti/personality_data.dart';

class MbtiCalculator {
  // Her bir temel MBTI boyutunu tutar ve başlangıçta 0'dır.
  // Örneğin: 'E' pozitif, 'I' negatif skorları biriktirecek.
  // E - I = Net Skor.
  Map<String, int> scores = {
    'E': 0,
    'S': 0,
    'T': 0,
    'J': 0,
    'I': 0,
    'N': 0,
    'F': 0,
    'P': 0,
  };

  void addScore(String scoreType, int value) {
    // value (+2'den -2'ye) 'scoreType' dimension'ına eklenecek.
    // Eğer scoreType 'E' ise:
    //   - value pozitifse E'yi artır.
    //   - value negatifse I'yı artır (çünkü E'ye -2 puan vermek, I'ya +2 vermektir).

    // Dimension'ın karşılığını bulma (E/I, S/N, T/F, J/P)
    String oppositeType;
    if (scoreType == 'E')
      oppositeType = 'I';
    else if (scoreType == 'I')
      oppositeType = 'E'; // Bu veri setinizde yok ama mantık için ekledik.
    else if (scoreType == 'S')
      oppositeType = 'N';
    else if (scoreType == 'N')
      oppositeType = 'S'; // Bu veri setinizde yok ama mantık için ekledik.
    else if (scoreType == 'T')
      oppositeType = 'F';
    else if (scoreType == 'F')
      oppositeType = 'T'; // Bu veri setinizde yok ama mantık için ekledik.
    else if (scoreType == 'J')
      oppositeType = 'P';
    else if (scoreType == 'P')
      oppositeType = 'J'; // Bu veri setinizde yok ama mantık için ekledik.
    else
      return; // Tanımsız tip

    // Puanlama:
    // Eğer seçilen 'scoreType' (örn. E) pozitif puan alıyorsa, ilgili tipi artır.
    // Eğer seçilen 'scoreType' (örn. E) negatif puan alıyorsa, karşıt tipi (I) artır.

    if (value > 0) {
      scores[scoreType] = (scores[scoreType] ?? 0) + value;
    } else if (value < 0) {
      // Negatif puanı pozitife çevirip karşıt tipe ekle
      scores[oppositeType] = (scores[oppositeType] ?? 0) + value.abs();
    }
    // value 0 ise hiçbir şey yapma (Neutral)
  }

  String calculateResult() {
    String result = '';

    // E-I (Net puan > 0 ise E, <= 0 ise I)
    int eiScore = (scores['E'] ?? 0) - (scores['I'] ?? 0);
    result += (eiScore >= 0) ? 'E' : 'I';

    // S-N
    int snScore = (scores['S'] ?? 0) - (scores['N'] ?? 0);
    result += (snScore >= 0) ? 'S' : 'N';

    // T-F
    int tfScore = (scores['T'] ?? 0) - (scores['F'] ?? 0);
    result += (tfScore >= 0) ? 'T' : 'F';

    // J-P
    int jpScore = (scores['J'] ?? 0) - (scores['P'] ?? 0);
    result += (jpScore >= 0) ? 'J' : 'P';

    return result;
  }

  void reset() {
    scores = {'E': 0, 'S': 0, 'T': 0, 'J': 0, 'I': 0, 'N': 0, 'F': 0, 'P': 0};
  }

  PersonalityResult getPersonalityResult() {
    // 1. 4 harfli sonucu hesapla (örn: 'ENFJ')
    String mbtiType = calculateResult();

    // 2. 'personalityData' haritasından bu tipe karşılık gelen sonucu bul.
    //    Eğer 'mbtiType' haritada bulunamazsa (ki bu imkansız olmalı),
    //    varsayılan olarak 'INTJ' sonucunu döndür.
    return personalityData[mbtiType]!;
  }
}
