import 'package:flutter/material.dart';
import 'splash_styles.dart';

class SplashContent extends StatelessWidget {
  final Animation<double> fadeAnim;
  final Animation<double> scaleAnim;
  final Animation<int> textAnim;

  const SplashContent({
    super.key,
    required this.fadeAnim,
    required this.scaleAnim,
    required this.textAnim,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnim,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: scaleAnim,
              child: Icon(
                Icons.auto_awesome,
                size: 80,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 20),
            AnimatedBuilder(
              animation: textAnim,
              builder: (context, child) {
                String text = "M${"entra".substring(0, textAnim.value)}";
                return Text(text, style: SplashStyles.logoTextStyle);
              },
            ),
          ],
        ),
      ),
    );
  }
}
