// lib/pages/home/home_test_section.dart
import 'package:flutter/material.dart';
import 'home_logic.dart';

class HomeTestSection extends StatefulWidget {
  final bool isDark;
  const HomeTestSection({super.key, required this.isDark});

  @override
  State<HomeTestSection> createState() => _HomeTestSectionState();
}

class _HomeTestSectionState extends State<HomeTestSection> {
  String _response = "No data yet.";

  void _runTest() async {
    final res = await HomeLogic.sendToBackend();
    setState(() => _response = res);
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isDark ? Colors.white70 : Colors.black87;
    return Column(
      children: [
        const SizedBox(height: 20),
        Divider(color: color.withOpacity(0.3)),
        Text(_response, style: TextStyle(color: color)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: [
            ElevatedButton(
              onPressed: _runTest,
              child: const Text("Test Backend"),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pushNamed(context, '/document-processor'),
              child: const Text("Doc Processor"),
            ),
          ],
        ),
      ],
    );
  }
}
