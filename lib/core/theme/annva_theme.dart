import 'package:flutter/material.dart';

import 'annva_colors.dart';
import 'annva_spacing.dart';

/// Annva Design System — ThemeData Builder
///
/// Heritage Indigo theme: cream backgrounds, deep indigo primary,
/// ochre accents, warm neutrals throughout. Never cool grays.
class AnnvaTheme {
  AnnvaTheme._();

  /// Light theme — the primary Annva experience.
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AnnvaColors.background,
      colorScheme: const ColorScheme.light(
        primary: AnnvaColors.primary,
        onPrimary: AnnvaColors.primaryForeground,
        secondary: AnnvaColors.ochre,
        onSecondary: AnnvaColors.ochreForeground,
        surface: AnnvaColors.backgroundCard,
        onSurface: AnnvaColors.foreground,
        error: AnnvaColors.cascadeUrgent,
        outline: AnnvaColors.border,
      ),

      // ─── APP BAR ───
      appBarTheme: const AppBarTheme(
        backgroundColor: AnnvaColors.background,
        foregroundColor: AnnvaColors.primary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'InstrumentSerif',
          fontSize: 22,
          fontWeight: FontWeight.w400,
          color: AnnvaColors.primary,
        ),
      ),

      // ─── BOTTOM NAV ───
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AnnvaColors.backgroundCard,
        selectedItemColor: AnnvaColors.primary,
        unselectedItemColor: AnnvaColors.muted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // ─── CARDS ───
      cardTheme: CardThemeData(
        color: AnnvaColors.backgroundCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AnnvaRadius.lg),
          side: const BorderSide(color: AnnvaColors.border, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),

      // ─── ELEVATED BUTTON (Primary CTA) ───
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AnnvaColors.primary,
          foregroundColor: AnnvaColors.primaryForeground,
          elevation: 0,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AnnvaRadius.full),
          ),
          textStyle: const TextStyle(
            fontFamily: 'WorkSans',
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // ─── OUTLINED BUTTON (Secondary / Chip-style) ───
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AnnvaColors.primary,
          backgroundColor: AnnvaColors.backgroundCard,
          elevation: 0,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AnnvaRadius.full),
          ),
          side: const BorderSide(color: AnnvaColors.border, width: 0.5),
          textStyle: const TextStyle(
            fontFamily: 'WorkSans',
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // ─── TEXT BUTTON ───
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AnnvaColors.primary,
          textStyle: const TextStyle(
            fontFamily: 'WorkSans',
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // ─── INPUT DECORATION ───
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AnnvaColors.backgroundCard,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AnnvaRadius.md),
          borderSide: const BorderSide(
            color: AnnvaColors.borderLight,
            width: 0.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AnnvaRadius.md),
          borderSide: const BorderSide(
            color: AnnvaColors.borderLight,
            width: 0.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AnnvaRadius.md),
          borderSide: const BorderSide(color: AnnvaColors.primary, width: 1.5),
        ),
        hintStyle: const TextStyle(
          fontFamily: 'WorkSans',
          fontSize: 14,
          color: AnnvaColors.mutedForeground,
        ),
        labelStyle: const TextStyle(
          fontFamily: 'WorkSans',
          fontSize: 14,
          color: AnnvaColors.muted,
        ),
      ),

      // ─── CHIP ───
      chipTheme: ChipThemeData(
        backgroundColor: AnnvaColors.backgroundCard,
        selectedColor: AnnvaColors.primary,
        labelStyle: const TextStyle(
          fontFamily: 'WorkSans',
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AnnvaRadius.full),
          side: const BorderSide(color: AnnvaColors.border, width: 0.5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),

      // ─── DIVIDER ───
      dividerTheme: const DividerThemeData(
        color: AnnvaColors.border,
        thickness: 0.5,
        space: 0,
      ),

      // ─── TEXT THEME — fallback base text styles ───
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'InstrumentSerif',
          fontSize: 56,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.5,
          color: AnnvaColors.primary,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'InstrumentSerif',
          fontSize: 32,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.3,
          color: AnnvaColors.primary,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'InstrumentSerif',
          fontSize: 24,
          fontWeight: FontWeight.w400,
          color: AnnvaColors.primary,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'InstrumentSerif',
          fontSize: 20,
          fontWeight: FontWeight.w400,
          color: AnnvaColors.primary,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'WorkSans',
          fontSize: 15,
          fontWeight: FontWeight.w400,
          height: 1.6,
          color: AnnvaColors.foreground,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'WorkSans',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.5,
          color: AnnvaColors.foreground,
        ),
        bodySmall: TextStyle(
          fontFamily: 'WorkSans',
          fontSize: 13,
          fontWeight: FontWeight.w400,
          height: 1.5,
          color: AnnvaColors.muted,
        ),
        labelLarge: TextStyle(
          fontFamily: 'WorkSans',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AnnvaColors.primaryForeground,
        ),
        labelSmall: TextStyle(
          fontFamily: 'WorkSans',
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.2,
          color: AnnvaColors.ochre,
        ),
      ),
    );
  }

  /// Dark theme — reserved for future implementation.
  /// Uses the dark mode equivalents defined in AnnvaColors.
  static ThemeData dark() {
    // TODO: Implement dark mode using AnnvaColors.backgroundDark, cardDark, borderDark
    return light().copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AnnvaColors.backgroundDark,
    );
  }
}
