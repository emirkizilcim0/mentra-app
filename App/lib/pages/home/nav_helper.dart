import 'package:flutter/material.dart';
import 'package:mentra_app/pages/chat/chat_page.dart';
import 'package:mentra_app/services/dairy/dairy_service.dart';

import 'package:intl/intl.dart';

Future<void> handleDiarySelection(
  BuildContext context,
  DateTime date,
  Function onBack,
) async {
  final targetStr = DateFormat('EEE, d MMM yyyy').format(date);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Searching for $targetStr...'),
      duration: const Duration(seconds: 2),
    ),
  );

  try {
    final entries = await DiaryService.getDiaryEntries();
    final exists = entries.any((e) => e['formattedDate'] == targetStr);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    if (!exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Entry not found, opening empty page.'),
          backgroundColor: Colors.orange,
        ),
      );
    }

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatPage(selectedDate: date)),
    );
    onBack();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Critical error loading diary.'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
