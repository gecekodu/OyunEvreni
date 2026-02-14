// 🎨 Uygulama Tema Ayarları

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 🎮 Oyunsal Renkler - Logo ve karakterle uyumlu
  static const Color primaryColor = Color(0xFF00D4FF); // Neon camgobegi
  static const Color secondaryColor = Color(0xFFFF4D9A); // Neon pembe
  static const Color accentColor = Color(0xFF8BFF6B); // Neon yesil
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFe74c3c);
  static const Color warningColor = Color(0xFFf39c12);

  // Tamamlayici oyunsal renkler
  static const Color gameBlue = Color(0xFF6BD6FF);
  static const Color gamePink = Color(0xFFFF7BC8);
  static const Color gameCyan = Color(0xFF43F5FF);
  static const Color gameGreen = Color(0xFF8BFF6B);

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
      surface: const Color(0xFFFFFBF0),
    ),
    scaffoldBackgroundColor: const Color(0xFFF5FBFF),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Color(0xFFEAF7FF),
      foregroundColor: Color(0xFF102036),
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(color: Color(0xFF102036)),
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Color(0xFF102036),
        letterSpacing: 0.2,
      ),
    ),
    textTheme: GoogleFonts.fredokaTextTheme().apply(
      bodyColor: const Color(0xFF102036),
      displayColor: const Color(0xFF102036),
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
      fillColor: const Color(0xFFEAF6FF),
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
      backgroundColor: const Color(0xFFEAF7FF),
      elevation: 8,
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: primaryColor, size: 28);
        }
        return const IconThemeData(color: Color(0xFF456080), size: 24);
      }),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    textTheme: GoogleFonts.fredokaTextTheme(ThemeData.dark().textTheme).apply(
      bodyColor: Colors.white70,
      displayColor: Colors.white70,
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      primary: primaryColor,
      secondary: secondaryColor,
      surface: const Color(0xFF2C2A3D),
    ),
    scaffoldBackgroundColor: const Color(0xFF1F1C2B),
    appBarTheme: const AppBarTheme(
      elevation: 2,
      centerTitle: true,
      backgroundColor: Color(0xFF2C2A3D),
      foregroundColor: Color(0xFFFFC46B),
    ),
    cardTheme: CardThemeData(
      color: Color(0xFF2C2A3D),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Color(0xFF2C2A3D),
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
