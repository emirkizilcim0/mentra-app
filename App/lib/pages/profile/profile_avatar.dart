import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final bool isDark;
  const ProfileAvatar({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black54 : Colors.grey.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(Icons.person, size: 60, color: Colors.grey[700]),
      ),
    );
  }
}
