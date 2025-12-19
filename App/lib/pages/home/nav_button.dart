import 'package:flutter/material.dart';

class NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;

  const NavButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: isDark ? Colors.white : Colors.black87),
      onPressed: onTap,
    );
  }
}
