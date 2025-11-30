import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';

class DiaryWritePage extends StatefulWidget {
  const DiaryWritePage({super.key});

  @override
  State<DiaryWritePage> createState() => _DiaryWritePageState();
}

class _DiaryWritePageState extends State<DiaryWritePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveDiary() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final diaryEntry = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': _titleController.text,
        'content': _contentController.text,
        'date': now.toIso8601String(),
        'formattedDate': DateFormat('dd MMMM yyyy, HH:mm').format(now),
      };

      Navigator.pop(context, diaryEntry);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode
          ? const Color(0xFF121212) // Dark mode background
          : Colors.white, // Light mode background
      appBar: AppBar(
        backgroundColor: themeProvider.isDarkMode
            ? const Color(0xFF1E1E1E) // Dark mode appbar
            : Colors.white, // Light mode appbar
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: themeProvider.isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Write Diary',
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white : Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveDiary,
            child: Text(
              'Save',
              style: TextStyle(
                color: themeProvider.isDarkMode
                    ? Colors
                          .deepPurpleAccent // Dark mode save color
                    : Colors.deepPurple, // Light mode save color
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Diary Title',
                  hintStyle: TextStyle(
                    color: themeProvider.isDarkMode
                        ? Colors.grey[500] // Dark mode hint
                        : Colors.grey[400], // Light mode hint
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.isDarkMode
                      ? Colors
                            .white // Dark mode text
                      : Colors.black, // Light mode text
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat('dd MMMM yyyy, HH:mm').format(DateTime.now()),
                style: TextStyle(
                  color: themeProvider.isDarkMode
                      ? Colors.grey[400] // Dark mode date
                      : Colors.grey[600], // Light mode date
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: TextFormField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    hintText: 'How was your day? Share your thoughts...',
                    hintStyle: TextStyle(
                      color: themeProvider.isDarkMode
                          ? Colors.grey[500] // Dark mode hint
                          : Colors.grey[400], // Light mode hint
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    color: themeProvider.isDarkMode
                        ? Colors
                              .white // Dark mode text
                        : Colors.black87, // Light mode text
                    height: 1.5,
                  ),
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please write something about your day';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
