import 'package:flutter/material.dart';
import 'advice_list.dart';

class AdviceViewBody extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final List<Map<String, dynamic>> items;
  final bool isDark;

  const AdviceViewBody({
    super.key,
    required this.isLoading,
    this.error,
    required this.items,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (error != null) {
      return Center(
        child: Text(
          error!,
          style: TextStyle(
            color: isDark ? Colors.redAccent[100] : Colors.redAccent,
          ),
        ),
      );
    }
    return AdviceList(items: items, isDark: isDark);
  }
}
