// lib/screen_mixin.dart
import 'package:flutter/material.dart';
import 'package:mentra_app/pages/documents/document_processor_screen.dart';
import 'logic_text.dart';
import 'logic_connection.dart';
import 'logic_personality.dart';

mixin ScreenMixin on State<DocumentProcessorScreen> {
  String result = "Welcome to Mentra Document Processor!";
  bool loading = false;
  final TextEditingController textCtrl = TextEditingController();

  void updateState(String res) => setState(() {
    result = res;
    loading = false;
  });

  Future<void> runProcess() async {
    if (textCtrl.text.isEmpty) {
      setState(() => result = "Please enter some text to process");
      return;
    }
    setState(() {
      loading = true;
      result = "Processing...";
    });
    updateState(await TextLogic.process(textCtrl.text));
  }

  Future<void> runTest() async {
    setState(() {
      loading = true;
      result = "Testing backend...";
    });
    updateState(await ConnectionLogic.test());
  }

  Future<void> runPersonality() async {
    setState(() {
      loading = true;
      result = "Loading test...";
    });
    updateState(await PersonalityLogic.loadTest());
  }

  void clear() {
    textCtrl.clear();
    setState(() => result = "Ready for new input...");
  }
}
