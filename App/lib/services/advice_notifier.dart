// lib/services/advice_notifier.dart
import 'package:flutter/foundation.dart';

class AdviceNotifier extends ChangeNotifier {
  // Singleton instance
  static final AdviceNotifier _instance = AdviceNotifier._internal();
  factory AdviceNotifier() => _instance;
  AdviceNotifier._internal();

  // Track when new advice is created
  int _newAdviceCount = 0;
  DateTime? _lastAdviceCreatedAt;

  // Getter for new advice count
  int get newAdviceCount => _newAdviceCount;
  DateTime? get lastAdviceCreatedAt => _lastAdviceCreatedAt;

  // Method to notify that new advice was created
  void notifyNewAdviceCreated() {
    _newAdviceCount++;
    _lastAdviceCreatedAt = DateTime.now();
    print('📢 AdviceNotifier: New advice created (total: $_newAdviceCount)');
    notifyListeners();
  }

  // Method to reset the count (when user views the advice)
  void resetNewAdviceCount() {
    _newAdviceCount = 0;
    notifyListeners();
  }

  // Check if there are new advices
  bool get hasNewAdvices => _newAdviceCount > 0;
}
