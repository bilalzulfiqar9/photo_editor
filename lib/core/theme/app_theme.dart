import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color primary = Color(0xFF7B2CBF);
  static const Color onBackground = Colors.white;
  static const Color onSurface = Colors.white;
  static const Color onSurfaceVariant = Color(0xFFAAAAAA);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        surface: surface,
        onSurface: onSurface,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme)
          .copyWith(
            displayLarge: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: onBackground,
            ),
            headlineMedium: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: onBackground,
            ),
            titleLarge: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: onBackground,
            ),
            titleMedium: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: onBackground,
            ),
            bodyMedium: GoogleFonts.outfit(
              fontSize: 14,
              color: onSurfaceVariant,
            ),
          ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Outfit',
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: onBackground,
        ),
        iconTheme: IconThemeData(color: onBackground),
      ),
    );
  }
}
