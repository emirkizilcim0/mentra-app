import 'dart:math';
import 'package:mentra_app/data/horoscope_data.dart'; // Veri dosyanı import et

class LocalHoroscopeService {
  // CSV ile hiçbir işimiz kalmadı. Direkt String dönüyoruz.
  static Future<String> getDailyMessage(String sign) async {
    try {
      // 1. Veri havuzundan burca ait listeyi çek
      // Gelen burç isminin ilk harfini büyütüp kalanı küçük yapıyoruz (Aries, Taurus...)
      final String formattedSign =
          sign[0].toUpperCase() + sign.substring(1).toLowerCase();

      // Listeyi al (Eğer burç bulunamazsa boş liste döner)
      final List<String>? messages =
          HoroscopeData.zodiacMessages[formattedSign];

      // Eğer liste yoksa veya boşsa hata mesajı dön
      if (messages == null || messages.isEmpty) {
        return "Insight not available for $formattedSign today.";
      }

      // 2. MANTIK: Güne Özel Sabit Rastgelelik
      // Bugünün tarihini al
      final now = DateTime.now();

      // Bir "Tohum" (Seed) oluştur.
      // Yıl + Ay + Gün + Burç İsminin Uzunluğu.
      // Bu sayı gün boyunca DEĞİŞMEZ. Yarın değişir.
      final int seed =
          (now.year * 10000) +
          (now.month * 100) +
          now.day +
          formattedSign.length;

      // Bu tohumu kullanarak Random oluştur.
      // Seed sabit olduğu için, nextInt() her zaman aynı sonucu verir (o gün için).
      final random = Random(seed);

      // 3. Listeden rastgele bir mesaj seç
      final int randomIndex = random.nextInt(messages.length);

      return messages[randomIndex];
    } catch (e) {
      print("Horoscope Error: $e");
      return "Unlock your potential today with a positive mindset."; // Fallback mesaj
    }
  }
}
