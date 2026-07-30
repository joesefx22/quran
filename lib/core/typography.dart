import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  // الخط الأساسي للواجهة
  static final TextStyle baseStyle = GoogleFonts.cairo();

  // أنماط النص القرآني (خط عثماني)
  static const String quranFontFamily = 'Uthmanic';

  static TextStyle quranAyah({double fontSize = 22, Color? color}) {
    return TextStyle(
      fontFamily: quranFontFamily,
      fontSize: fontSize,
      color: color ?? Colors.black87,
      height: 1.8,
      letterSpacing: 0.5,
    );
  }

  // أنماط جاهزة للعناوين والنصوص
  static TextStyle headline(BuildContext context) {
    return Theme.of(context).textTheme.headlineMedium!.copyWith(
          fontFamily: baseStyle.fontFamily,
          fontWeight: FontWeight.bold,
        );
  }

  static TextStyle body(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge!.copyWith(
          fontFamily: baseStyle.fontFamily,
        );
  }

  static TextStyle button(BuildContext context) {
    return Theme.of(context).textTheme.labelLarge!.copyWith(
          fontFamily: baseStyle.fontFamily,
          fontWeight: FontWeight.w600,
        );
  }
}