// pages/mood/range_selector.dart
import 'package:flutter/material.dart';
import 'package:mentra_app/services/mood_repository.dart';

class RangeSelector extends StatelessWidget {
  final MoodRange selectedRange;
  final ValueChanged<MoodRange> onRangeSelected;

  const RangeSelector({
    super.key,
    required this.selectedRange,
    required this.onRangeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildChip('Day', MoodRange.day),
          const SizedBox(width: 4),
          _buildChip('Week', MoodRange.week),
          const SizedBox(width: 4),
          _buildChip('Month', MoodRange.month),
        ],
      ),
    );
  }

  Widget _buildChip(String label, MoodRange range) {
    final isSelected = selectedRange == range;

    return InkWell(
      onTap: () => onRangeSelected(range),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
