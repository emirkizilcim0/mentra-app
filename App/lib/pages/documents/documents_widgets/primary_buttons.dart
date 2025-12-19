// lib/primary_buttons.dart
import 'package:flutter/material.dart';

class PrimaryButtons extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onProcess;
  final VoidCallback onTest;

  const PrimaryButtons({
    required this.isLoading,
    required this.onProcess,
    required this.onTest,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: isLoading ? null : onProcess,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
            child: Text('Process Text'),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: OutlinedButton(
            onPressed: isLoading ? null : onTest,
            child: Text('Test Connection'),
          ),
        ),
      ],
    );
  }
}
