// lib/document_processor_screen.dart
import 'package:flutter/material.dart';
import 'package:mentra_app/pages/documents/documents_widgets/input_widget.dart';
import 'package:mentra_app/pages/documents/documents_widgets/primary_buttons.dart';
import 'package:mentra_app/pages/documents/documents_widgets/result_display.dart';
import 'package:mentra_app/pages/documents/documents_widgets/screen_mixin.dart';
import 'package:mentra_app/pages/documents/documents_widgets/secondary_buttons.dart';

class DocumentProcessorScreen extends StatefulWidget {
  @override
  _DocumentProcessorScreenState createState() =>
      _DocumentProcessorScreenState();
}

class _DocumentProcessorScreenState extends State<DocumentProcessorScreen>
    with ScreenMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mentra Document Processor'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            InputWidget(controller: textCtrl),
            SizedBox(height: 20),
            PrimaryButtons(
              isLoading: loading,
              onProcess: runProcess,
              onTest: runTest,
            ),
            SizedBox(height: 10),
            SecondaryButtons(
              isLoading: loading,
              onLoadTest: runPersonality,
              onClear: clear,
            ),
            SizedBox(height: 20),
            if (loading) LinearProgressIndicator(),
            SizedBox(height: 20),
            Expanded(child: ResultDisplay(text: result)),
          ],
        ),
      ),
    );
  }
}
