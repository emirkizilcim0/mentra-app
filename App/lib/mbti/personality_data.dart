// personality_result_model.dart

import 'package:flutter/material.dart';

// Kişilik sonuç verilerini taşımak için model sınıfı
class PersonalityResult {
  final String type; // Örn: 'ENFJ'
  final String title; // Örn: 'Kahraman'
  final String description;
  final Color color;

  PersonalityResult({
    required this.type,
    required this.title,
    required this.description,
    required this.color,
  });
}

// Tüm 16 kişilik tipi için veri seti
final Map<String, PersonalityResult> personalityData = {
  // Analistler (Mavi tonlar)
  'INTJ': PersonalityResult(
    type: 'INTJ',
    title: 'Mimar',
    description: 'Stratejik düşünürler, her şey için bir planı olanlar...',
    color: Colors.indigo.shade700,
  ),
  'INTP': PersonalityResult(
    type: 'INTP',
    title: 'Mantıkçı',
    description: 'Sürekli bilgi peşinde koşan, yaratıcı mucitler...',
    color: Colors.blueGrey.shade700,
  ),
  'ENTJ': PersonalityResult(
    type: 'ENTJ',
    title: 'Komutan',
    description:
        'Karizmatik ve ilham verici liderler, cesur irade gücüne sahip...',
    color: Colors.blue.shade700,
  ),
  'ENTP': PersonalityResult(
    type: 'ENTP',
    title: 'Tartışmacı',
    description:
        'Zeki ve meraklı düşünürler, zihinsel mücadeleleri severler...',
    color: Colors.cyan.shade700,
  ),

  // Diplomatlar (Yeşil tonlar)
  'INFJ': PersonalityResult(
    type: 'INFJ',
    title: 'Savunucu',
    description: 'Sessiz ve mistik, ilham verici idealistler...',
    color: Colors.teal.shade700,
  ),
  'INFP': PersonalityResult(
    type: 'INFP',
    title: 'Arabulucu',
    description: 'Şairane, nazik ve fedakâr, her zaman iyilik arayanlar...',
    color: Colors.lightGreen.shade700,
  ),
  'ENFJ': PersonalityResult(
    type: 'ENFJ',
    title: 'Kahraman',
    description: 'Coşkulu, karizmatik ve ilham verici liderler...',
    color: Colors.green.shade700,
  ),
  'ENFP': PersonalityResult(
    type: 'ENFP',
    title: 'Kampanyacı',
    description: 'Yaratıcı, sosyal, özgür ruhlu ve neşe yayanlar...',
    color: Colors.lime.shade700,
  ),

  // Gözcüler (Sarı/Turuncu tonlar)
  'ISTJ': PersonalityResult(
    type: 'ISTJ',
    title: 'Lojistikçi',
    description: 'Gerçekçi, sorumluluk sahibi, gelenekselciler...',
    color: Colors.brown.shade700,
  ),
  'ISFJ': PersonalityResult(
    type: 'ISFJ',
    title: 'Savunmacı',
    description: 'Özenli, sıcakkanlı ve koruyucu, sessiz kahramanlar...',
    color: Colors.amber.shade700,
  ),
  'ESTJ': PersonalityResult(
    type: 'ESTJ',
    title: 'Yönetici',
    description:
        'Mükemmel yöneticiler, işleri organize eden ve uygulayanlar...',
    color: Colors.orange.shade700,
  ),
  'ESFJ': PersonalityResult(
    type: 'ESFJ',
    title: 'Konsül',
    description: 'Son derece sosyal, popüler ve yardım etmeyi sevenler...',
    color: Colors.deepOrange.shade700,
  ),

  // Kaşifler (Kırmızı/Gri tonlar)
  'ISTP': PersonalityResult(
    type: 'ISTP',
    title: 'Sanatkâr',
    description: 'Cesur, pratik deneyiciler, elleriyle çalışmayı sevenler...',
    color: Colors.grey.shade700,
  ),
  'ISFP': PersonalityResult(
    type: 'ISFP',
    title: 'Maceracı',
    description:
        'Esnek, büyüleyici sanatçılar, her zaman yeni şeyler denemeye hazır...',
    color: Colors.pink.shade700,
  ),
  'ESTP': PersonalityResult(
    type: 'ESTP',
    title: 'Girişimci',
    description: 'Zeki, enerjik ve çok algılayan, risk almayı sevenler...',
    color: Colors.red.shade700,
  ),
  'ESFP': PersonalityResult(
    type: 'ESFP',
    title: 'Eğlendirici',
    description: 'Spontane, enerjik ve hayatı dolu dolu yaşayanlar...',
    color: Colors.purple.shade700,
  ),
};
