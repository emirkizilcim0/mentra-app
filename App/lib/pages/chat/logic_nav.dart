import 'package:flutter/material.dart';
import 'package:mentra_app/pages/dairy/detail/dairy_detail_page.dart';
import 'chat_utils.dart';
import 'selection_dialog.dart';

class LogicNav {
  static void checkForAutoOpen(
    BuildContext context,
    DateTime? selectedDate,
    List<Map<String, dynamic>> entries,
    bool isDark,
  ) {
    if (selectedDate == null) return;
    final targetStr = formatDateForComparison(selectedDate);
    final dailyEntries = entries
        .where((e) => e['formattedDate'] == targetStr)
        .toList();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (dailyEntries.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$targetStr için günlük bulunamadı.'),
            backgroundColor: Colors.orange,
          ),
        );
      } else if (dailyEntries.length == 1) {
        openDiaryDetail(context, dailyEntries.first);
      } else {
        showDiarySelectionPopup(
          context,
          dailyEntries,
          isDark,
          (entry) => openDiaryDetail(context, entry),
        );
      }
    });
  }

  static void openDiaryDetail(
    BuildContext context,
    Map<String, dynamic> entry,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DiaryDetailPage(diaryEntry: entry)),
    );
  }
}
