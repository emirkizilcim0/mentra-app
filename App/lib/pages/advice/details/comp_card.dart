// lib/comp_card.dart
import 'package:flutter/material.dart';
import 'advice_colors.dart';

class CompCard extends StatelessWidget {
  final bool isDark;
  final List<Widget> children;

  const CompCard({required this.isDark, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdviceColors.card(isDark),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AdviceColors.shadow(isDark),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
