/*
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final bool isDark;
  final Animation<double> floatAnim;
  final Animation<double> opacityAnim;
  final int dotCount;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.isDark,
    required this.floatAnim,
    required this.opacityAnim,
    required this.dotCount,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isLoading ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: IgnorePointer(
        ignoring: !isLoading,
        child: AbsorbPointer(
          absorbing: true,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: (isDark ? Colors.black : Colors.white).withOpacity(0.7),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: floatAnim,
                      builder: (ctx, child) => Transform.translate(
                        offset: Offset(0, floatAnim.value),
                        child: child,
                      ),
                      child: Image.asset(
                        'assets/logo.png',
                        width: 300,
                        height: 300,
                      ),
                    ),
                    const SizedBox(height: 20),
                    FadeTransition(
                      opacity: opacityAnim,
                      child: Text(
                        "Mentra Yükleniyor${List.filled(dotCount, '.').join()}",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
*/
