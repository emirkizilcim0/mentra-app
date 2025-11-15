import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Write Diary',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveDiary,
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.deepPurple,
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
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
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
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: TextFormField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    hintText: 'How was your day? Share your thoughts...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
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
