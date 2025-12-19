import 'dart:ui';
import 'package:flutter/material.dart';

class BlurIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const BlurIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: (isDark ? Colors.black : Colors.white).withOpacity(0.3),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: (isDark ? Colors.white : Colors.white).withOpacity(
                isDark ? 0.2 : 0.5,
              ),
            ),
          ),
          child: IconButton(
            icon: Icon(
              icon,
              color: Theme.of(context).colorScheme.onBackground,
              size: 24,
            ),
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }
}
