import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DatePickerField extends StatelessWidget {
  final DateTime? date;
  final VoidCallback onTap;

  const DatePickerField({super.key, required this.date, required this.onTap});

  String _formatDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final text = date == null ? 'Select your birth date' : _formatDate(date!);

    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Birth Date',
          border: OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
            ),
            const Icon(Icons.calendar_today, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}
