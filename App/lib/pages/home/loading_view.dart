// lib/pages/home/loading_view.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:ui';

class LoadingView extends StatefulWidget {
  final bool isDark;

  const LoadingView({super.key, required this.isDark});

  @override
  State<LoadingView> createState() => _LoadingViewState();
}

class _LoadingViewState extends State<LoadingView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<double> _floatAnimation;

  int _dotCount = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _opacityAnimation = Tween(
      begin: 0.3,
      end: 1.0,
    ).animate(_animationController);

    _floatAnimation = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutSine,
      ),
    );

    _animationController.repeat(reverse: true);
    _startDotAnimation();
  }

  void _startDotAnimation() {
    _timer?.cancel();
    _dotCount = 0;
    _timer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (mounted) {
        setState(() {
          _dotCount++;
          if (_dotCount > 3) _dotCount = 0;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String dots = "." * _dotCount;

    // BURADAKİ DEĞİŞİKLİĞE DİKKAT:
    // Scaffold yerine Material widget'ı kullanıyoruz.
    // type: MaterialType.transparency -> Arka planı şeffaf yapar, böylece blur görünür.
    return Material(
      type: MaterialType.transparency, // Sarı çizgiyi çözen sihirli satır
      child: Stack(
        children: [
          // Arka plan bulanıklığı
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              color: widget.isDark
                  ? Colors.black.withOpacity(0.6)
                  : Colors.white.withOpacity(0.6),
            ),
          ),

          // İçerik
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _opacityAnimation.value,
                      child: Transform.translate(
                        offset: Offset(0, _floatAnimation.value),
                        child: Image.asset(
                          'assets/logo.png', // Logo yolunu kontrol et
                          width: 250,
                          height: 250,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  "Loading$dots",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    // Eğer Material kullanmazsan buraya decoration: TextDecoration.none eklemen gerekirdi
                    color: widget.isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
