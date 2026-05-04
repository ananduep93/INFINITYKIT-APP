import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF2563EB); // Modern Blue
  static const Color accentColor = Color(0xFF3B82F6); 
  static const Color backgroundColor = Color(0xFFF8FAFC); // Very Light Gray/White
  static const Color cardColor = Colors.white;
  static const Color textColor = Color(0xFF1E293B); // Dark Slate for text
  static const Color subtitleColor = Color(0xFF64748B);

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    cardColor: cardColor,
    textTheme: GoogleFonts.outfitTextTheme(
      const TextTheme(
        headlineLarge: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 32),
        headlineMedium: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 24),
        bodyLarge: TextStyle(color: textColor, fontSize: 16),
        bodyMedium: TextStyle(color: subtitleColor, fontSize: 14),
      ),
    ),
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
      surface: cardColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: textColor),
      titleTextStyle: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 20),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryColor,
      unselectedItemColor: subtitleColor,
      elevation: 10,
    ),
  );
}
