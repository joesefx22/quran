import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme.dart';
import '../core/typography.dart';

class IslamicHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showMotif;

  const IslamicHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showMotif = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.emeraldGreen, Color(0xFF03885E)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.emeraldGreen.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          if (showMotif)
            Positioned(
              left: -10,
              top: -10,
              child: Opacity(
                opacity: 0.15,
                child: SvgPicture.asset(
                  'assets/icons/islamic_pattern.svg',
                  width: 160,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: AppTypography.headline().copyWith(     // تم إزالة context
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: AppTypography.body().copyWith(        // تم إزالة context
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0);
  }
}