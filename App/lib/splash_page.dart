import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mentra_app/login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
        // 📢 Burayı değiştirdik!
        with
        TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _scaleAnimation;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  late AnimationController _textController;
  late Animation<int> _textAnimation;

  final String _fullWord = "Mentra";
  final String _animatedPart = "entra";

  void _startLoadingAndNavigate() async {
    // 1. Minimum animasyon süresini belirle (Metin animasyonu 1.5 saniye sürdüğü için)
    const Duration minDuration = Duration(milliseconds: 1500);

    // 2. Eş zamansız yükleme/kontrol işlemlerini burada yap
    // Örneğin, yetkilendirme kontrolü veya veri yükleme:
    Future<void> loadingTasks = Future.wait([
      // Örnek: Gerçek bir asenkron görev (örneğin SharedPreferences.getInstance() gibi)
      Future.delayed(const Duration(milliseconds: 500)),
      // Auth kontrolü, veri çekme vb. ek asenkron işlemler burada yer almalı.
    ]);

    // 3. Yükleme görevlerinin ve minimum animasyon süresinin (1.5 saniye) bitmesini bekle
    // Bu, hem işlemlerin bitmesini hem de animasyonun tamamen oynanmasını garanti eder.
    await Future.wait([
      loadingTasks,
      minDuration.delayed, // Timer yerine Future.delayed kullanıldı.
    ]);

    // 4. Eğer widget hala ekrandaysa (mounted) ve animasyon tamamlanmadıysa (ki bu dinleyici
    // ile kontrol ediliyor), güvenli bir geçiş yap.
    // NOT: Sizin kodunuzdaki geçiş zaten _textController.addStatusListener içinde.
    // Bu metod sadece asenkron yüklemeleri yönetmek için kullanıldı.
  }

  @override
  void initState() {
    super.initState();

    // 1. FADE-IN ANİMASYONU
    _fadeController = AnimationController(
      vsync: this, // Artık TickerProviderStateMixin tarafından destekleniyor
      duration: const Duration(seconds: 1),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();

    // 2. LOGO BÜYÜYÜP KÜÇÜLME ANİMASYONU
    _logoController = AnimationController(
      vsync: this, // Artık TickerProviderStateMixin tarafından destekleniyor
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    _logoController.repeat(reverse: true);

    // 3. YAZI YAZDIRMA ANİMASYONU
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1500,
      ), // Yazdırma süresi: 1.5 saniye
    );

    // 0'dan, animasyon yapılacak kısmın uzunluğuna (5) kadar sayar.
    _textAnimation = IntTween(
      begin: 0,
      end: _animatedPart.length,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.linear));

    // Animasyonu başlat
    _textController.forward();

    _textController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Widget hala ağaçtaysa ve sayfadan çıkılmamışsa geçişi yap
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const LoginPage(), // LoginScreen'i burada kullanın
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _logoController.stop();
    _fadeController.stop();
    _textController.stop();

    _logoController.dispose();
    _fadeController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(200, 72, 49, 95),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _logoController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Image.asset(
                      'assets/logo.png',
                      width: 300,
                      height: 300,
                    ),
                  );
                },
              ),

              // MENTRA YAZISI VE YAZDIRMA ANİMASYONU
              AnimatedBuilder(
                animation: _textController,
                builder: (context, child) {
                  // Animasyonun o anki değerine (0'dan 5'e) göre alt kelimeyi al.
                  final int charCount = _textAnimation.value;
                  final String currentSuffix = _animatedPart.substring(
                    0,
                    charCount,
                  );
                  return Row(
                    mainAxisSize: MainAxisSize
                        .min, // Row'un kendini içeriğe göre küçültmesini sağlar
                    children: [
                      // Sabit 'M' harfi
                      Text(
                        _fullWord[0],
                        style: GoogleFonts.pacifico(
                          fontSize: 40,
                          color: Color.fromARGB(221, 248, 248, 248),
                        ),
                      ),

                      // Animasyonlu 'entra' kısmı
                      Text(
                        currentSuffix, // Harfler sağa doğru eklenir
                        style: GoogleFonts.pacifico(
                          fontSize: 40,
                          color: const Color.fromARGB(221, 255, 254, 254),
                        ),
                      ),
                    ],
                  );

                  // 'M' harfini sabit tutup, kalan kısmı animasyonlu olarak ekle
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

extension on Duration {
  Future get delayed => Future.delayed(this);
}
