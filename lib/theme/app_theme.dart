// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Backgrounds
  static const Color bg = Color(0xFF050A13);
  static const Color bgCard = Color(0xFF0D1526);
  static const Color bgSurface = Color(0xFF0A1020);

  // Neon Accents
  static const Color neonCyan = Color(0xFF00F5FF);
  static const Color neonPurple = Color(0xFFBF00FF);
  static const Color neonBlue = Color(0xFF0080FF);
  static const Color neonGreen = Color(0xFF00FF88);
  static const Color neonPink = Color(0xFFFF006E);

  // Text
  static const Color textPrimary = Color(0xFFECF4FF);
  static const Color textSecondary = Color(0xFF7B93B8);
  static const Color textMuted = Color(0xFF3D5475);

  // UI Elements
  static const Color border = Color(0xFF1A2E4A);
  static const Color borderGlow = Color(0xFF00F5FF);
  static const Color divider = Color(0xFF0F1E33);

  // Gradients
  static const LinearGradient cyanGradient = LinearGradient(
    colors: [Color(0xFF00F5FF), Color(0xFF0080FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFFBF00FF), Color(0xFF7000FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF0D1B2E), Color(0xFF08101C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.neonCyan,
        secondary: AppColors.neonPurple,
        surface: AppColors.bgCard,
        background: AppColors.bg,
        error: AppColors.neonPink,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.orbitron(
          fontSize: 32,
          fontWeight: FontWeight.w900,
          color: AppColors.textPrimary,
          letterSpacing: 2,
        ),
        displayMedium: GoogleFonts.orbitron(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: 1.5,
        ),
        displaySmall: GoogleFonts.orbitron(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        headlineLarge: GoogleFonts.rajdhani(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: 1,
        ),
        headlineMedium: GoogleFonts.rajdhani(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineSmall: GoogleFonts.rajdhani(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.exo2(
          fontSize: 16,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: GoogleFonts.exo2(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
        bodySmall: GoogleFonts.exo2(
          fontSize: 12,
          color: AppColors.textMuted,
        ),
        labelLarge: GoogleFonts.rajdhani(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.neonCyan,
          letterSpacing: 1.5,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.neonCyan, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.neonPink),
        ),
        hintStyle: GoogleFonts.exo2(color: AppColors.textMuted),
        labelStyle: GoogleFonts.exo2(color: AppColors.textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.neonCyan,
          foregroundColor: AppColors.bg,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.rajdhani(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            letterSpacing: 1.5,
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.bgSurface,
        selectedItemColor: AppColors.neonCyan,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bg,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.orbitron(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
    );
  }
}
