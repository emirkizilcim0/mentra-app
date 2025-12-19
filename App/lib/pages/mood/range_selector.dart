import 'package:flutter/material.dart';
import 'package:mentra_app/services/mood_repository.dart'; // MoodRange enum'ı için

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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildChip('Hafta', MoodRange.week),
        const SizedBox(width: 8),
        _buildChip('Ay', MoodRange.month),
        const SizedBox(width: 8),
        _buildChip('Yıl', MoodRange.year),
      ],
    );
  }

  Widget _buildChip(String label, MoodRange range) {
    return ChoiceChip(
      label: Text(label),
      selected: selectedRange == range,
      onSelected: (selected) {
        if (selected) onRangeSelected(range);
      },
    );
  }
}
