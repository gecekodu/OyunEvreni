// 🎨 Uygulama Tema Ayarları

import 'package:flutter/material.dart';

class AppTheme {
  // 🎮 Oyunsal Renkler - Logo ve karakterle uyumlu
  static const Color primaryColor = Color(0xFFFFC300); // Altin
  static const Color secondaryColor = Color(0xFF6C5CE7); // Mor
  static const Color accentColor = Color(0xFF4DD6FF); // Canli mavi
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFe74c3c);
  static const Color warningColor = Color(0xFFf39c12);

  // Tamamlayici oyunsal renkler
  static const Color gameBlue = Color(0xFF5B8CFF);
  static const Color gamePink = Color(0xFFFF6FB1);
  static const Color gameCyan = Color(0xFF4DD6FF);
  static const Color gameGreen = Color(0xFF48D597);

  // Light Theme - Oyunsal ve canlı
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      surface: const Color(0xFFF7F6FF),
    ),
    scaffoldBackgroundColor: const Color(0xFFF3F2FF),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Color(0xFFF3F2FF),
      foregroundColor: Color(0xFF1F1A35),
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(color: Color(0xFF1F1A35)),
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1F1A35),
        letterSpacing: 0.2,
      ),
    ),
    textTheme: const TextTheme(
      bodySmall: TextStyle(color: Color(0xFF1F1A35)),
      bodyMedium: TextStyle(color: Color(0xFF1F1A35)),
      bodyLarge: TextStyle(color: Color(0xFF1F1A35)),
      titleSmall: TextStyle(color: Color(0xFF1F1A35)),
      titleMedium: TextStyle(color: Color(0xFF1F1A35)),
      titleLarge: TextStyle(color: Color(0xFF1F1A35)),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 6,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF1EEFF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      elevation: 8,
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: primaryColor, size: 28);
        }
        return const IconThemeData(color: Colors.grey, size: 24);
      }),
    ),
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      primary: primaryColor,
      secondary: secondaryColor,
      surface: const Color(0xFF241B45),
    ),
    scaffoldBackgroundColor: const Color(0xFF1A1333),
    appBarTheme: const AppBarTheme(
      elevation: 2,
      centerTitle: true,
      backgroundColor: Color(0xFF211A3D),
      foregroundColor: Color(0xFFFFC300),
    ),
    cardTheme: CardThemeData(
      color: Color(0xFF241B45),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Color(0xFF211A3D),
      elevation: 8,
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: primaryColor, size: 28);
        }
        return const IconThemeData(color: Colors.white70, size: 24);
      }),
    ),
  );
}
