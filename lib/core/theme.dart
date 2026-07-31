import 'package:flutter/material.dart';
import 'typography.dart';

class AppTheme {
  static const Color emeraldGreen = Color(0xFF047857);
  static const Color warmGold = Color(0xFFD4AF37);
  static const Color darkSlate = Color(0xFF1E2A38);
  static const Color ivory = Color(0xFFFDFBF7);
  static const Color deepNavy = Color(0xFF0B1E2E);
  static const Color softWhite = Color(0xFFF5F5F5);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: emeraldGreen,
      brightness: Brightness.light,
      primary: emeraldGreen,
      onPrimary: Colors.white,
      surface: ivory,
      onSurface: darkSlate,
      background: ivory,
      onBackground: darkSlate,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: ivory,
      fontFamily: AppTypography.baseStyle.fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: ivory.withOpacity(0.8),
        foregroundColor: darkSlate,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        titleTextStyle: AppTypography.headline(color: darkSlate).copyWith(fontSize: 20),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: emeraldGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: AppTypography.button(color: Colors.white),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: emeraldGreen,
          side: const BorderSide(color: emeraldGreen),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: emeraldGreen, width: 2),
        ),
        hintStyle: TextStyle(color: darkSlate.withOpacity(0.5)),
      ),
      textTheme: TextTheme(
        headlineLarge: AppTypography.headline(color: darkSlate).copyWith(fontSize: 28, fontWeight: FontWeight.bold),
        headlineMedium: AppTypography.headline(color: darkSlate).copyWith(fontSize: 22, fontWeight: FontWeight.w600),
        bodyLarge: AppTypography.body(color: darkSlate).copyWith(fontSize: 16, height: 1.5),
        bodyMedium: AppTypography.body(color: darkSlate.withOpacity(0.8)).copyWith(fontSize: 14, height: 1.4),
        labelLarge: AppTypography.button(color: darkSlate).copyWith(fontSize: 16, letterSpacing: 0.5),
      ),
      dividerTheme: DividerThemeData(
        color: warmGold.withOpacity(0.3),
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(color: emeraldGreen),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return emeraldGreen;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return warmGold;
          return Colors.grey;
        }),
        trackColor: WidgetStateProperty.all(emeraldGreen.withOpacity(0.3)),
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: emeraldGreen,
      brightness: Brightness.dark,
      primary: emeraldGreen,
      onPrimary: Colors.white,
      surface: deepNavy,
      onSurface: softWhite,
      background: const Color(0xFF000000),
      onBackground: softWhite,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF000000),
      fontFamily: AppTypography.baseStyle.fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF000000).withOpacity(0.85),
        foregroundColor: softWhite,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        titleTextStyle: AppTypography.headline(color: softWhite).copyWith(fontSize: 20),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF121212),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: emeraldGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: AppTypography.button(color: Colors.white),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: emeraldGreen, width: 2),
        ),
        hintStyle: TextStyle(color: softWhite.withOpacity(0.5)),
      ),
      textTheme: TextTheme(
        headlineLarge: AppTypography.headline(color: softWhite).copyWith(fontSize: 28, fontWeight: FontWeight.bold),
        headlineMedium: AppTypography.headline(color: softWhite).copyWith(fontSize: 22, fontWeight: FontWeight.w600),
        bodyLarge: AppTypography.body(color: softWhite).copyWith(fontSize: 16, height: 1.5),
        bodyMedium: AppTypography.body(color: softWhite.withOpacity(0.8)).copyWith(fontSize: 14, height: 1.4),
        labelLarge: AppTypography.button(color: softWhite).copyWith(fontSize: 16, letterSpacing: 0.5),
      ),
      dividerTheme: DividerThemeData(
        color: warmGold.withOpacity(0.3),
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(color: emeraldGreen),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return emeraldGreen;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return warmGold;
          return Colors.grey;
        }),
        trackColor: WidgetStateProperty.all(emeraldGreen.withOpacity(0.3)),
      ),
    );
  }
}