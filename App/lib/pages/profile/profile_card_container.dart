import 'package:flutter/material.dart';

class ProfileCardContainer extends StatelessWidget {
  final Widget child;
  const ProfileCardContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1.5),
      ),
      child: child,
    );
  }
}
