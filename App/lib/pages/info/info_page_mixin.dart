// lib/info_page_mixin.dart
import 'package:flutter/material.dart';
import 'info_page.dart';

mixin InfoPageMixin on State<InfoPage> {
  final nameController = TextEditingController();
  final birthdayController = TextEditingController();
  final signController = TextEditingController();
  final timeController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    birthdayController.dispose();
    signController.dispose();
    timeController.dispose();
    super.dispose();
  }

  List<TextEditingController> get controllers => [
    nameController,
    birthdayController,
    signController,
    timeController,
  ];
}
