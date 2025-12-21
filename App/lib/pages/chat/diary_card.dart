import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'chat_styles.dart';
import 'chat_utils.dart';
import 'package:intl/intl.dart';

// Global permanent storage for app session
final Set<String> _permanentAdviceMemory = Set();

class DiaryCard extends StatelessWidget {
  final Map<String, dynamic> entry;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onAdvice;

  const DiaryCard({
    super.key,
    required this.entry,
    required this.isDark,
    required this.onTap,
    required this.onAdvice,
  });

  // Helper to check if advice exists PERMANENTLY
  bool _hasPermanentAdvice() {
    String localId = entry['id']?.toString() ?? entry['_id']?.toString() ?? "";

    // Check 1: Global memory (app session)
    if (_permanentAdviceMemory.contains(localId)) {
      return true;
    }

    // Check 2: PostgreSQL flag (from database)
    if (entry['has_advice'] == true) {
      _permanentAdviceMemory.add(localId); // Remember for session
      return true;
    }

    // Check 3: Any advice/analysis data exists
    bool hasData =
        (entry['advice'] != null &&
            entry['advice'].toString().trim().isNotEmpty) ||
        (entry['analysis'] != null &&
            entry['analysis'].toString().trim().isNotEmpty);

    if (hasData) {
      _permanentAdviceMemory.add(localId); // Remember for session
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    String localId = entry['id']?.toString() ?? entry['_id']?.toString() ?? "";
    bool hasAdvice = _hasPermanentAdvice();

    // Debug
    print('🎯 DiaryCard - ID: $localId, Has Advice: $hasAdvice');

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: getCardColor(isDark),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [getShadow(isDark)],
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry['date'] != null
                        ? DateFormat('d MMMM, yyyy').format(
                            entry['date'] is DateTime
                                ? entry['date']
                                : DateTime.parse(entry['date'].toString()),
                          )
                        : 'No date',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: getTextColor(isDark),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry['title'] ?? titleFromContent(entry['content'] ?? ''),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // --- PERMANENT BUTTON LOGIC ---
            if (hasAdvice)
              InkWell(
                onTap: () {
                  // Add to permanent memory for this app session
                  _permanentAdviceMemory.add(localId);
                  onAdvice();
                },
                child: Container(
                  margin: const EdgeInsets.only(left: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green, // PERMANENT GREEN
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.visibility, size: 16, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(
                        'See Advice',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              InkWell(
                onTap: () {
                  // Will be marked as having advice in _getAdvice function
                  onAdvice();
                },
                child: Container(
                  margin: const EdgeInsets.only(left: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome, size: 16, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(
                        'Get Advice',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
