import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CropDocColors {
  CropDocColors._();

  // Primary earthy greens
  static const Color primary = Color(0xFF2D6A4F);
  static const Color primaryLight = Color(0xFF40916C);
  static const Color primaryDark = Color(0xFF1B4332);

  // Warm accents
  static const Color secondary = Color(0xFFD4A373);
  static const Color secondaryLight = Color(0xFFE6CBA8);

  // Status colors
  static const Color danger = Color(0xFFC1121F);
  static const Color dangerLight = Color(0xFFFFE0E3);
  static const Color warning = Color(0xFFE9C46A);
  static const Color warningLight = Color(0xFFFFF8E1);
  static const Color safe = Color(0xFF52B788);
  static const Color safeLight = Color(0xFFD8F3DC);

  // Backgrounds
  static const Color background = Color(0xFFFEFAE0);
  static const Color surface = Color(0xFFFFF8E7);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color darkSurface = Color(0xFF1B1B1B);
  static const Color darkOverlay = Color(0xCC1B1B1B);

  // Text
  static const Color textPrimary = Color(0xFF2B2B2B);
  static const Color textSecondary = Color(0xFF6B705C);
  static const Color textMuted = Color(0xFF9B9B8A);
  static const Color textOnDark = Color(0xFFFEFAE0);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Misc
  static const Color divider = Color(0xFFE8E4D9);
  static const Color shimmer = Color(0xFFE8E4D9);
}

class CropDocTheme {
  CropDocTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: CropDocColors.background,
      colorScheme: const ColorScheme.light(
        primary: CropDocColors.primary,
        primaryContainer: CropDocColors.primaryLight,
        secondary: CropDocColors.secondary,
        surface: CropDocColors.surface,
        error: CropDocColors.danger,
        onPrimary: CropDocColors.textOnPrimary,
        onSurface: CropDocColors.textPrimary,
        onSecondary: CropDocColors.textPrimary,
      ),
      textTheme: _textTheme,
      cardTheme: CardThemeData(
        color: CropDocColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: CropDocColors.divider, width: 0.5),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CropDocColors.primary,
          foregroundColor: CropDocColors.textOnPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: CropDocColors.primary,
          side: const BorderSide(color: CropDocColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: CropDocColors.textPrimary,
        ),
        iconTheme: const IconThemeData(
          color: CropDocColors.textPrimary,
        ),
      ),
      iconTheme: const IconThemeData(
        color: CropDocColors.textSecondary,
        size: 24,
      ),
      dividerTheme: const DividerThemeData(
        color: CropDocColors.divider,
        thickness: 0.5,
        space: 1,
      ),
    );
  }

  static TextTheme get _textTheme {
    return TextTheme(
      headlineLarge: GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: CropDocColors.textPrimary,
        height: 1.2,
      ),
      headlineMedium: GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: CropDocColors.textPrimary,
        height: 1.25,
      ),
      headlineSmall: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: CropDocColors.textPrimary,
        height: 1.3,
      ),
      titleLarge: GoogleFonts.outfit(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: CropDocColors.textPrimary,
      ),
      titleMedium: GoogleFonts.outfit(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: CropDocColors.textPrimary,
      ),
      bodyLarge: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: CropDocColors.textPrimary,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: CropDocColors.textSecondary,
        height: 1.45,
      ),
      bodySmall: GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: CropDocColors.textMuted,
        height: 1.4,
      ),
      labelLarge: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: CropDocColors.textPrimary,
        letterSpacing: 0.3,
      ),
      labelMedium: GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: CropDocColors.textSecondary,
      ),
      labelSmall: GoogleFonts.outfit(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: CropDocColors.textMuted,
        letterSpacing: 0.5,
      ),
    );
  }
}
