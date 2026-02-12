// 🎨 Uygulama Tema Ayarları

import 'package:flutter/material.dart';

class AppTheme {
  // 🎮 Oyunsal Renkler - Logo ve karakterle uyumlu
  static const Color primaryColor = Color(0xFFFF9500); // Ana turuncu
  static const Color secondaryColor = Color(0xFF7B1FA2); // Lezzetli mor
  static const Color accentColor = Color(0xFFFFC107); // Sarı vurgu
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFe74c3c);
  static const Color warningColor = Color(0xFFf39c12);
  
  // Tamamlayıcı oyunsal renkler
  static const Color gameBlue = Color(0xFF1E88E5);
  static const Color gamePink = Color(0xFFE91E63);
  static const Color gameCyan = Color(0xFF0097A7);
  static const Color gameGreen = Color(0xFF00897B);

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
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(color: Colors.black87),
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
        letterSpacing: 0.2,
      ),
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
      fillColor: Colors.grey[100],
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
    ),
    appBarTheme: const AppBarTheme(
      elevation: 2,
      centerTitle: true,
      backgroundColor: Color(0xFF2a2a2a),
      foregroundColor: primaryColor,
    ),
  );
}
