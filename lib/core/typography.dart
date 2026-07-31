import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  static final TextStyle baseStyle = GoogleFonts.cairo();

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

  static TextStyle headline({Color? color}) {
    return baseStyle.copyWith(
      fontWeight: FontWeight.bold,
      color: color,
    );
  }

  static TextStyle body({Color? color}) {
    return baseStyle.copyWith(
      color: color,
    );
  }

  static TextStyle button({Color? color}) {
    return baseStyle.copyWith(
      fontWeight: FontWeight.w600,
      color: color,
    );
  }
}