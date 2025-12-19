import 'dart:async';
import 'package:flutter/material.dart';

class AnimationHelper {
  Timer? _timer;
  int dotCount = 0;

  void startDotAnimation(bool isLoading, Function(int) onUpdate) {
    _timer?.cancel();
    dotCount = 0;

    _timer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (isLoading) {
        dotCount++;
        if (dotCount > 3) dotCount = 0;
        onUpdate(dotCount);
      } else {
        timer.cancel();
        onUpdate(3);
      }
    });
  }

  void dispose() {
    _timer?.cancel();
  }
}
