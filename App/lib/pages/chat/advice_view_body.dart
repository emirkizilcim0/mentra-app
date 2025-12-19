import 'package:flutter/material.dart';
import 'advice_list.dart';

class AdviceViewBody extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final List<Map<String, dynamic>> analyses;
  final bool isDark;

  const AdviceViewBody({
    super.key,
    required this.isLoading,
    this.errorMessage,
    required this.analyses,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorMessage != null) {
      return Center(
        child: Text(
          errorMessage!,
          style: TextStyle(
            color: isDark ? Colors.redAccent[100] : Colors.redAccent,
          ),
        ),
      );
    }
    return AdviceList(analyses: analyses, isDark: isDark);
  }
}
