import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Application theme configuration
class AppTheme {
  // Light Theme Colors
  static const Color primaryLight = Color(0xFF7C4DFF); // Electric Purple
  static const Color secondaryLight = Color(0xFFFF00E5); // Neon Magenta
  static const Color backgroundLight = Color(0xFFFFFFFF); // Pure White
  static const Color surfaceLight = Color(0xFFF7F7F7); // Cool Gray-White
  static const Color textPrimaryLight = Color(0xFF000000); // Deep Charcoal
  static const Color textSecondaryLight = Color(
    0xFF757575,
  ); // Medium Grasurfacey

  // Dark Theme Colors
  static const Color primaryDark = Color(0xFF9D7AFF); // Soft Neon Purple
  static const Color secondaryDark = Color(0xFF00F0FF); // Electric Cyan
  static const Color backgroundDark = Color(0xFF171717); // Deep Obsidian
  static const Color surfaceDark = Color(0xFF242424); // Midnight Gray
  static const Color textPrimaryDark = Color(0xFFFFFFFF); // White
  static const Color textSecondaryDark = Color(0xFFA0A0A0); // Silver Gray

  /// Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: backgroundLight,
    primaryColor: primaryLight,
    cardColor: surfaceLight,

    colorScheme: const ColorScheme.light(
      primary: primaryLight,
      secondary: secondaryLight,
      surface: surfaceLight,
      error: Color(0xFFEF4444),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimaryLight,
      onError: Colors.white,
      outline: Color.fromARGB(255, 207, 207, 207),
    ),

    // Typography
    textTheme: GoogleFonts.funnelSansTextTheme().copyWith(
      displayLarge: GoogleFonts.funnelSans(
        fontSize: 38,
        fontWeight: FontWeight.w600,
        color: textPrimaryLight,
      ),
      displayMedium: GoogleFonts.funnelSans(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: textPrimaryLight,
      ),
      displaySmall: GoogleFonts.funnelSans(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textPrimaryLight,
      ),
      headlineMedium: GoogleFonts.funnelSans(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textPrimaryLight,
      ),
      titleLarge: GoogleFonts.funnelSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimaryLight,
      ),
      bodyLarge: GoogleFonts.funnelSans(fontSize: 16, color: textPrimaryLight),
      bodyMedium: GoogleFonts.funnelSans(fontSize: 14, color: textPrimaryLight),
    ),

    // AppBar Theme
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: backgroundLight,
      foregroundColor: textPrimaryLight,
      titleTextStyle: GoogleFonts.funnelSans(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textPrimaryLight,
      ),
      iconTheme: const IconThemeData(color: textPrimaryLight),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      elevation: 0, // Flat design as requested
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: surfaceLight,
      margin: EdgeInsets.zero,
    ),

    // Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryLight,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.funnelSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceLight,
      hintStyle: GoogleFonts.funnelSans(color: textSecondaryLight),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryLight, width: 2),
      ),
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      elevation: 0,
      backgroundColor: Colors.white,
      selectedItemColor: primaryLight,
      unselectedItemColor: textSecondaryLight,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
    ),
  );

  /// Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundDark,
    primaryColor: primaryDark,
    cardColor: surfaceDark,

    colorScheme: const ColorScheme.dark(
      primary: primaryDark,
      secondary: secondaryDark,
      surface: surfaceDark,
      error: Color(0xFFEF4444),
      onPrimary: Colors.white,
      onSecondary: Colors.black, // Dark text on light accent
      onSurface: textPrimaryDark,
      onError: Colors.white,
      outline: Color.fromARGB(255, 63, 63, 63),
    ),

    // Typography
    textTheme: GoogleFonts.funnelSansTextTheme().copyWith(
      displayLarge: GoogleFonts.funnelSans(
        fontSize: 38,
        fontWeight: FontWeight.w600,
        color: textPrimaryDark,
      ),
      displayMedium: GoogleFonts.funnelSans(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: textPrimaryDark,
      ),
      displaySmall: GoogleFonts.funnelSans(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textPrimaryDark,
      ),
      headlineMedium: GoogleFonts.funnelSans(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textPrimaryDark,
      ),
      titleLarge: GoogleFonts.funnelSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimaryDark,
      ),
      bodyLarge: GoogleFonts.funnelSans(fontSize: 16, color: textPrimaryDark),
      bodyMedium: GoogleFonts.funnelSans(fontSize: 14, color: textPrimaryDark),
    ),

    // AppBar Theme
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: backgroundDark,
      foregroundColor: textPrimaryDark,
      titleTextStyle: GoogleFonts.funnelSans(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textPrimaryDark,
      ),
      iconTheme: const IconThemeData(color: textPrimaryDark),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: surfaceDark,
      margin: EdgeInsets.zero,
    ),

    // Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.funnelSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceDark,
      hintStyle: GoogleFonts.funnelSans(color: textSecondaryDark),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryDark, width: 2),
      ),
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      elevation: 0,
      backgroundColor: Color.fromARGB(255, 114, 114, 114),
      selectedItemColor: primaryDark,
      unselectedItemColor: textSecondaryDark,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
    ),
  );
}
