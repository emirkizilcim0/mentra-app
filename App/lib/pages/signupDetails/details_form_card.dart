import 'package:flutter/material.dart';
import 'details_styles.dart';

class DetailsFormCard extends StatelessWidget {
  final Widget child;
  const DetailsFormCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: DetailsStyles.cardDecoration,
      child: child,
    );
  }
}
