import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFC9A688),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFFAF9F6),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFFC9A688),
        foregroundColor: const Color(0xFF2D2A26),
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Color(0xFFC9A688),
        foregroundColor: Color(0xFF2D2A26),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(color: Color(0xFF2D2A26), fontSize: 32, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: Color(0xFF2D2A26), fontSize: 28, fontWeight: FontWeight.w600),
        displaySmall: TextStyle(color: Color(0xFF2D2A26), fontSize: 24, fontWeight: FontWeight.w500),
        headlineLarge: TextStyle(color: Color(0xFF2D2A26), fontSize: 22, fontWeight: FontWeight.w500),
        headlineMedium: TextStyle(color: Color(0xFF2D2A26), fontSize: 18, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: Color(0xFF2D2A26), fontSize: 16),
        bodyMedium: TextStyle(color: Color(0xFF2D2A26), fontSize: 14),
        bodySmall: TextStyle(color: Color(0xFF2D2A26).withValues(alpha: 0.6), fontSize: 12),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFE8E4DC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: const Color(0xFFF5F5F5)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE57373)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFC9A688), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
