import 'package:flutter/material.dart';

class AnswerCircle extends StatelessWidget {
  final int value;
  final bool isSelected;
  final double size;
  final Color baseColor;
  final VoidCallback onTap;

  const AnswerCircle({
    super.key,
    required this.value,
    required this.isSelected,
    required this.size,
    required this.baseColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // Seçiliyse kendi rengi, değilse beyaz
          color: isSelected ? baseColor : Colors.white,
          border: Border.all(
            // Seçiliyse kendi rengi, değilse gri çerçeve
            color: isSelected ? baseColor : Colors.grey.shade400,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: baseColor.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
      ),
    );
  }
}
