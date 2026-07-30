import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme.dart';
import '../core/typography.dart';

class HalaqaCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? svgIconPath;
  final VoidCallback? onTap;
  final int index;

  const HalaqaCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.svgIconPath = 'assets/icons/quran_icon.svg',
    this.onTap,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
      elevation: 1.5,
      shadowColor: AppTheme.emeraldGreen.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          HapticFeedback.lightImpact();
          onTap?.call();
        },
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              if (svgIconPath != null)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.emeraldGreen.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SvgPicture.asset(
                    svgIconPath!,
                    width: 30,
                    height: 30,
                    colorFilter: const ColorFilter.mode(
                      AppTheme.emeraldGreen,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.headline(context).copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: AppTypography.body(context).copyWith(
                        color: AppTheme.warmGold,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: isDark ? Colors.grey[500] : AppTheme.darkSlate.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: (60 * index).ms)
        .slideX(begin: 0.1, end: 0, duration: 400.ms, delay: (60 * index).ms)
        .shimmer(
          delay: (300 + 40 * index).ms,
          duration: 900.ms,
          color: AppTheme.warmGold.withOpacity(0.15),
        );
  }
}