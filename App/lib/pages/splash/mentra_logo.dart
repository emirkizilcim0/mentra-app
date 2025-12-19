import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MentraLogo extends StatelessWidget {
  final Animation<double> scaleAnimation;
  final Animation<int> textAnimation;
  final AnimationController logoController;
  final AnimationController textController;

  const MentraLogo({
    super.key,
    required this.scaleAnimation,
    required this.textAnimation,
    required this.logoController,
    required this.textController,
  });

  @override
  Widget build(BuildContext context) {
    const String animatedPart = "entra";
    const String fullWord = "Mentra";

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 1. LOGO GÖRSELİ
        AnimatedBuilder(
          animation: logoController,
          builder: (context, child) {
            return Transform.scale(
              scale: scaleAnimation.value,
              child: Image.asset('assets/logo.png', width: 300, height: 300),
            );
          },
        ),

        // 2. MENTRA YAZISI VE ANİMASYONU
        AnimatedBuilder(
          animation: textController,
          builder: (context, child) {
            final int charCount = textAnimation.value;
            final String currentSuffix = animatedPart.substring(0, charCount);

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Sabit 'M'
                Text(
                  fullWord[0],
                  style: GoogleFonts.pacifico(
                    fontSize: 40,
                    color: const Color.fromARGB(221, 248, 248, 248),
                  ),
                ),
                // Animasyonlu 'entra'
                Text(
                  currentSuffix,
                  style: GoogleFonts.pacifico(
                    fontSize: 40,
                    color: const Color.fromARGB(221, 255, 254, 254),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
