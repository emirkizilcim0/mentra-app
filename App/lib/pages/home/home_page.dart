// lib/pages/home/home_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:mentra_app/providers/theme_provider.dart';
import 'package:mentra_app/motivational_speeches.dart'; // speeches için
import 'dialog_ui.dart';
import 'home_date_data.dart';
import 'home_days_generator.dart';
import 'home_view.dart';
import 'home_logic_loader.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, String> _days = {};
  Map<String, int> _percents = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    try {
      final data = await HomeLogicLoader.load();
      if (mounted)
        setState(() {
          _days = data['days'];
          _percents = data['percents'];
        });
    } catch (_) {}
  }

  void _showDetails(int d, int m, int y) {
    showDialog(
      context: context,
      builder: (_) =>
          DayDetailsDialog(date: DateTime(y, m + 1, d), hasEntry: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final dd = HomeDateData(DateTime.now(), speeches.length);

    return HomeView(
      isDark: isDark,
      dd: dd,
      dayWidgets: HomeDaysGenerator.generate(
        dd: dd,
        percents: _percents,
        days: _days,
        isDark: isDark,
        onDayTap: _showDetails,
      ),
    );
  }
}
