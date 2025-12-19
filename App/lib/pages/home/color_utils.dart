import 'package:flutter/material.dart';

Color fillForPercent(int percent, bool dark) {
  if (percent >= 75) {
    return dark
        ? Colors.green.shade900.withOpacity(0.25)
        : Colors.green.shade50;
  } else if (percent >= 50) {
    return dark
        ? Colors.amber.shade900.withOpacity(0.25)
        : Colors.amber.shade50;
  } else if (percent >= 25) {
    return dark
        ? Colors.orange.shade900.withOpacity(0.25)
        : Colors.orange.shade50;
  } else {
    return dark ? Colors.red.shade900.withOpacity(0.25) : Colors.red.shade50;
  }
}
