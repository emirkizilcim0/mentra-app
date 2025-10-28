import 'package:flutter/material.dart';
import 'bar_widgets/custom_header.dart';

// Ana Sayfa Widget'ı
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Sayfanın ana rengi için bir Color tanımlayalım
    // (Ekran görüntüsündeki açık mavi/beyaz gradyanını taklit etmek için)
    const Color lightBackgroundColor = Color(0xFFE0F7FA);

    return Scaffold(
      // Sayfanın arka planına gradyan uygulamak için Container kullanıyoruz
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            // Ekran görüntüsündeki açık pastel tonlarını taklit eden renkler
            colors: [
              Color(0xFFE0F7FA), // Çok açık mavi
              Color(0xFFFFFFFF), // Beyaz
            ],
          ),
        ),
        child: Column(
          children: [
            // Özel AppBar yerine, sayfanın içeriğinin bir parçası olarak başlık kısmı
            const CustomHeader(),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 30),

                    // 1. Profil Fotoğrafı
                    _buildProfileAvatar(),

                    const SizedBox(height: 40),

                    // 2. Bilgi Alanları Listesi
                    // Not: TextField'ları kullanmaya devam ediyoruz, ancak daha önceki _buildInfoTile metodunu kullanabilirsiniz.
                    const TextField(
                      decoration: InputDecoration(labelText: 'Name'),
                    ),
                    const SizedBox(height: 15),
                    const TextField(
                      decoration: InputDecoration(labelText: 'Character Type'),
                    ),
                    const SizedBox(height: 15),
                    const TextField(
                      decoration: InputDecoration(labelText: 'Sign'),
                    ),
                    const SizedBox(height: 15),
                    // 3. MBTI ve Buton
                    // Alt kısım için boşluk
                    _buildMbtiTile(context), // **CONTEXT EKLEMESİ YAPILDI**

                    const SizedBox(height: 40),
                    const Text('Birth Chart'),

                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // En alttaki gezinme çubuğu
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // Profil Fotoğrafı Widget'ı
  Widget _buildProfileAvatar() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(5.0), // Dış çerçeve boşluğu
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFFF48FB1), // Pembe çerçeve rengi
            width: 3.0,
          ),
        ),
        child: const CircleAvatar(
          radius: 50,
          backgroundColor: Color(0xFFF8BBD0), // Açık pembe arka plan
          child: Icon(Icons.person, size: 60, color: Colors.white),
        ),
      ),
    );
  }

  // MBTI Alanı ve Buton Widget'ı
  // **CONTEXT PARAMETRESİ EKLENDİ**
  Widget _buildMbtiTile(BuildContext context) {
    return Container(
      height: 55,
      padding: const EdgeInsets.only(left: 15, right: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "MBTI test",
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          // Take Again Butonu
          _buildTakeAgainButton(context), // **CONTEXT BUTONA İLETİLDİ**
        ],
      ),
    );
  }

  // Take Again Butonu Widget'ı
  // **CONTEXT PARAMETRESİ EKLENDİ**
  Widget _buildTakeAgainButton(BuildContext context) {
    return Container(
      width: 120, // Sabit genişlik
      height: 40, // Sabit yükseklik
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        // Ekran görüntüsündeki mor/pembe gradyanı
        gradient: const LinearGradient(
          colors: [
            Color(0xFFE91E63), // Koyu pembe
            Color(0xFFF06292), // Açık pembe
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent, // Material'ın kendi rengini şeffaf yapıyoruz
        child: InkWell(
          onTap: () {
            // 🚀 BURASI DÜZELTİLDİ: Tanımlı rota adı kullanılarak geçiş yapılıyor.
            Navigator.of(context).pushNamed('/testPage');
          },
          borderRadius: BorderRadius.circular(20),
          child: const Center(
            child: Text(
              "take again",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // En Alttaki Gezinme Çubuğu (Bottom Navigation Bar)
  Widget _buildBottomNavBar() {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: Color(0xFFF0F5F5), // Açık gri/mavi tonu
        border: Border(top: BorderSide(color: Color(0xFFB0BEC5), width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Ana Sayfa İkonu
          _buildNavBarItem(icon: Icons.home_outlined, isActive: true),
          // Profil İkonu
          _buildNavBarItem(icon: Icons.person_outline, isActive: false),
        ],
      ),
    );
  }

  // Navigasyon Çubuğu Öğesi
  Widget _buildNavBarItem({required IconData icon, required bool isActive}) {
    // İkonun üzerine yuvarlak bir halka (ring) ekliyoruz
    return Container(
      padding: const EdgeInsets.all(5.0),
      decoration: isActive
          ? BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.black87,
                width: 2,
              ), // Halka rengi
            )
          : null,
      child: Icon(icon, size: 30, color: Colors.black87),
    );
  }
}
