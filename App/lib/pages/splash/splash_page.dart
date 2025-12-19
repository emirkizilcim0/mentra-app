import 'package:flutter/material.dart';
import 'package:mentra_app/pages/splash/mentra_logo.dart';
import 'package:mentra_app/pages/splash/splash_logic.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _fadeCtrl, _logoCtrl, _textCtrl;
  late Animation<double> _fadeAnim, _scaleAnim;
  late Animation<int> _textAnim;

  @override
  void initState() {
    super.initState();

    // 1. FADE Animasyonu
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();

    // 2. LOGO SCALE Animasyonu
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnim = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeInOut));
    _logoCtrl.repeat(reverse: true);

    // 3. TEXT TYPING Animasyonu
    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _textAnim = IntTween(
      begin: 0,
      end: 5,
    ).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.linear));
    _textCtrl.forward();

    // 4. Animasyon bitince LOGIC dosyasını çalıştır
    _textCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        SplashLogic.navigateBasedOnAuth(context);
      }
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _logoCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(200, 72, 49, 95),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          // Modüler Logo Bileşeni
          child: MentraLogo(
            scaleAnimation: _scaleAnim,
            textAnimation: _textAnim,
            logoController: _logoCtrl,
            textController: _textCtrl,
          ),
        ),
      ),
    );
  }
}
