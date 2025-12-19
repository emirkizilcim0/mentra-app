import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isDark;
  final VoidCallback? onTap;

  const ProfileField({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isDark ? Colors.grey[400] : Colors.grey[600]),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: isDark ? Colors.grey[500] : Colors.grey[600],
                    ),
                  ),
                  Text(
                    value.isEmpty ? "Not set" : value,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.edit,
                size: 18,
                color: isDark ? Colors.grey[600] : Colors.grey[400],
              ),
          ],
        ),
      ),
    );
  }
}
