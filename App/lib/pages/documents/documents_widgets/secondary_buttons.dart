// lib/secondary_buttons.dart
import 'package:flutter/material.dart';

class SecondaryButtons extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onLoadTest;
  final VoidCallback onClear;

  const SecondaryButtons({
    required this.isLoading,
    required this.onLoadTest,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isLoading ? null : onLoadTest,
            child: Text('Load Test'),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: OutlinedButton(onPressed: onClear, child: Text('Clear')),
        ),
      ],
    );
  }
}
