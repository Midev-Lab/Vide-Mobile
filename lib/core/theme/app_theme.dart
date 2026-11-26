import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radii.dart';
import 'app_text_styles.dart';

/// Builds the Material [ThemeData] for light and dark modes.
class AppTheme {
  AppTheme._();

  // ─── Light theme ─────────────────────────────────────────────────────
  static ThemeData get light {
    const c = AppColors.light;
    return _build(Brightness.light, c);
  }

  // ─── Dark theme ──────────────────────────────────────────────────────
  static ThemeData get dark {
    const c = AppColors.dark;
    return _build(Brightness.dark, c);
  }

  // ─── Shared builder ──────────────────────────────────────────────────
  static ThemeData _build(Brightness brightness, AppColors c) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: c.green,
      onPrimary: Colors.white,
      secondary: c.send,
      onSecondary: Colors.white,
      error: c.error,
      onError: Colors.white,
      surface: c.card,
      onSurface: c.ink,
    );

    return ThemeData(
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: c.background,
      fontFamily: 'Fraunces',
      dividerColor: c.line,
      hoverColor: c.hover,
      cardTheme: CardThemeData(
        color: c.card,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.cards),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.card,
        border: OutlineInputBorder(
          borderRadius: AppRadii.composer,
          borderSide: BorderSide(color: c.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.composer,
          borderSide: BorderSide(color: c.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.composer,
          borderSide: BorderSide(color: c.green, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: AppTextStyles.input.copyWith(color: c.gray),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: AppRadii.pill),
          textStyle: AppTextStyles.button,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.green,
          side: BorderSide(color: c.line),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.pill),
          textStyle: AppTextStyles.button,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.green,
          textStyle: AppTextStyles.button,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.card,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadii.sheetsTopLarge,
        ),
        dragHandleColor: c.gray.withValues(alpha: 0.4),
        showDragHandle: true,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        foregroundColor: c.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
    );
  }
}
