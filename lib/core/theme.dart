import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFFF4A261);
  static const Color background = Color(0xFFFFF8F3);
  static const Color accent = Color(0xFFE9C46A);
  static const Color textMain = Color(0xFF2A2A2A);
  static const Color softShadow = Color(0x0A2A2A2A);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.light(
          primary: primary,
          secondary: accent,
          surface: background,
          onPrimary: Colors.white,
          onSecondary: textMain,
          onSurface: textMain,
        ),
        scaffoldBackgroundColor: background,
        fontFamily: 'System',
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textMain,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: textMain,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: textMain,
          ),
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadowColor: softShadow,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: background,
          foregroundColor: textMain,
          elevation: 0,
          centerTitle: true,
        ),
      );
}
