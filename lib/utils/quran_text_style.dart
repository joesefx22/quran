import 'package:flutter/material.dart';
import '../core/typography.dart';

class QuranTextStyle {
  static TextStyle ayah({double fontSize = 22, Color? color}) {
    return AppTypography.quranAyah(fontSize: fontSize, color: color);
  }

  // نمط للآيات داخل البطاقات مع إطار ذهبي خفيف
  static Widget styledAyah(String text, {double fontSize = 24}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppTheme.warmGold.withOpacity(0.4),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
        color: AppTheme.warmGold.withOpacity(0.05),
      ),
      child: Text(
        text,
        style: QuranTextStyle.ayah(fontSize: fontSize),
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
      ),
    );
  }
}