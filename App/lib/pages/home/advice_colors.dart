import 'package:flutter/material.dart';

Color getCardFill(int percent, bool dark) {
  if (percent >= 75)
    return dark
        ? Colors.green.shade900.withOpacity(0.25)
        : Colors.green.shade50;
  if (percent >= 50)
    return dark
        ? Colors.amber.shade900.withOpacity(0.25)
        : Colors.amber.shade50;
  if (percent >= 25)
    return dark
        ? Colors.orange.shade900.withOpacity(0.25)
        : Colors.orange.shade50;
  return dark ? Colors.red.shade900.withOpacity(0.25) : Colors.red.shade50;
}

Color getCardBorder(int percent, bool dark) {
  if (percent >= 75)
    return dark ? Colors.green.shade700 : Colors.green.shade400;
  if (percent >= 50)
    return dark ? Colors.amber.shade700 : Colors.amber.shade400;
  if (percent >= 25)
    return dark ? Colors.orange.shade700 : Colors.orange.shade400;
  return dark ? Colors.red.shade700 : Colors.red.shade400;
}
