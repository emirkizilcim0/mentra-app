import 'package:flutter/material.dart';

class CustomHeader extends StatelessWidget {
  const CustomHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Mentra",
              style: TextStyle(
                fontFamily: 'Pacifico', // özel font
                fontSize: 36,

                color: Color(0xFF000000), // yeşil ton
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.chat_bubble_outline,
                size: 28,
                color: Colors.black54,
              ),
              onPressed: () {
                // Konuşma balonuna basıldığında yapılacak işlem
              },
            ),
          ],
        ),
      ),
    );
  }
}
