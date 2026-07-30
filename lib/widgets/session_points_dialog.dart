import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/session_result.dart';
import '../core/theme.dart';

class SessionPointsDialog extends StatelessWidget {
  final SessionResult result;
  const SessionPointsDialog({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.emeraldGreen.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.check_circle_rounded,
                color: AppTheme.emeraldGreen, size: 28),
          ),
          const SizedBox(width: 12),
          const Text('تم حفظ التقرير',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _sectionTitle('الحضور والانضباط'),
            _row('الحضور', result.attendancePoints),
            _row('الحضور المبكر', result.earlyAttendancePoints),
            _row('التسميع المبكر', result.earlyRecitationPoints),
            _row('الانصراف', result.departurePoints),
            const SizedBox(height: 8),
            _sectionTitle('الحفظ الجديد'),
            _row('الجديد', result.newPoints),
            _row('الجديد الإضافي', result.newExtraPoints),
            const SizedBox(height: 8),
            _sectionTitle('المراجعة والتراكمي'),
            _row('المراجعة + التراكمي', result.reviewPoints + result.cumulativePoints),
            _row('المراجعة الإضافية', result.reviewExtraPoints),
            const Divider(color: AppTheme.warmGold, thickness: 1),
            _totalRow('الإجمالي', result.totalPoints),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('حسناً'),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppTheme.emeraldGreen,
          fontSize: 13,
          letterSpacing: 1,
        ),
        textAlign: TextAlign.right,
      ),
    );
  }

  Widget _row(String title, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
              child: Text(title,
                  style: const TextStyle(fontSize: 14))),
          Text(value.toStringAsFixed(2),
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _totalRow(String title, double value) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
              child: Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18))),
          Text('${value.toStringAsFixed(2)} نقطة',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppTheme.warmGold)),
        ],
      ),
    );
  }
}