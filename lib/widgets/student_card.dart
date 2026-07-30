import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/local_user.dart';
import '../core/theme.dart';

class StudentCard extends StatelessWidget {
  final LocalUser student;
  final double attendancePercent;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final int index;

  const StudentCard({
    super.key,
    required this.student,
    this.attendancePercent = 0,
    this.onTap,
    this.onLongPress,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = attendancePercent > 80 ? AppTheme.emeraldGreen : AppTheme.warmGold;

    return Card(
      color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          HapticFeedback.lightImpact();
          onTap?.call();
        },
        onLongPress: () {
          HapticFeedback.mediumImpact();
          onLongPress?.call();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
          child: Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 52,
                    height: 52,
                    child: CircularProgressIndicator(
                      value: attendancePercent / 100,
                      strokeWidth: 3.5,
                      backgroundColor: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.emeraldGreen,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.emeraldGreen.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      radius: 20,
                      child: Text(
                        student.fullName.isNotEmpty ? student.fullName[0] : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.fullName,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.check_circle_outline,
                            size: 14, color: AppTheme.warmGold),
                        const SizedBox(width: 4),
                        Text(
                          'الحضور: ${attendancePercent.toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: AppTheme.warmGold,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: isDark
                      ? Colors.grey[500]
                      : AppTheme.darkSlate.withOpacity(0.5)),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 350.ms, delay: (50 * index).ms)
        .slideY(begin: 0.1, end: 0, duration: 350.ms, delay: (50 * index).ms);
  }
}