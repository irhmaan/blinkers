// app_theme.dart
// Theme + Font utility using google_fonts

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();
  static const Color primary = Color(0xFF0B63D6);
  static const Color primaryVariant = Color(0xFF084FB0);
  static const Color secondary = Color(0xFF00BFA6);
  static const Color bg = Color(0xFFF7F9FC);
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFB00020);
}

class AppFonts {
  AppFonts._();

  // Use GoogleFonts to create TextStyle objects. These are convenient defaults
  // -- call AppFonts.h1, AppFonts.body, etc. from widgets or use AppTheme's textTheme.

  static TextStyle h1([Color? color]) => GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: color,
  );

  static TextStyle h2([Color? color]) => GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: color,
  );

  static TextStyle subtitle([Color? color]) => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: color,
  );

  static TextStyle body([Color? color]) => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: color,
  );

  static TextStyle caption([Color? color]) => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: color,
  );
}

class AppTheme {
  AppTheme._();

  static final _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    secondary: AppColors.secondary,
    onSecondary: Colors.white,
    error: AppColors.error,
    onError: Colors.white,
    surfaceContainer: AppColors.bg,
    onSurfaceVariant: Colors.black87,
    surface: AppColors.surface,
    onSurface: Colors.black87,
  );

  static ThemeData get lightTheme {
    final base = ThemeData.light();
    return base.copyWith(
      colorScheme: _lightColorScheme,
      primaryColor: _lightColorScheme.primary,
      scaffoldBackgroundColor: _lightColorScheme.surfaceContainer,
      appBarTheme: AppBarTheme(
        backgroundColor: _lightColorScheme.primary,
        foregroundColor: _lightColorScheme.onPrimary,
        elevation: 0,
        titleTextStyle: AppFonts.h2(_lightColorScheme.onPrimary),
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: AppFonts.h1(_lightColorScheme.onSurface),
        displayMedium: AppFonts.h2(_lightColorScheme.onSurface),
        titleMedium: AppFonts.subtitle(_lightColorScheme.onSurface),
        bodyLarge: AppFonts.body(_lightColorScheme.onSurface),
        bodySmall: AppFonts.caption(_lightColorScheme.onSurface),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: AppFonts.subtitle(Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      cardTheme: CardTheme(
        color: _lightColorScheme.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static final _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF4DA6FF),
    onPrimary: Colors.black,
    secondary: Color(0xFF66E0C1),
    onSecondary: Colors.black,
    error: AppColors.error,
    onError: Colors.white,
    // surface: Color(0xFF0B1020),
    onSurface: Colors.white70,
    surface: Color(0xFF0F1724),
    // onSurface: Colors.white70,
  );

  static ThemeData get darkTheme {
    final base = ThemeData.dark();
    return base.copyWith(
      colorScheme: _darkColorScheme,
      primaryColor: _darkColorScheme.primary,
      scaffoldBackgroundColor: _darkColorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: _darkColorScheme.surface,
        foregroundColor: _darkColorScheme.onSurface,
        elevation: 0,
        titleTextStyle: AppFonts.h2(_darkColorScheme.onSurface),
      ),

      textTheme: GoogleFonts.interTextTheme().copyWith(
        labelLarge: AppFonts.h1(_darkColorScheme.onSurface),
        displayLarge: AppFonts.h1(_darkColorScheme.onSurface),
        bodyLarge: AppFonts.h1(_darkColorScheme.onSurface),
        titleMedium: AppFonts.caption(_darkColorScheme.onSurface),
        displayMedium: AppFonts.body(_darkColorScheme.onSurface),
        bodySmall: AppFonts.body(_darkColorScheme.onSurface),
        bodyMedium: AppFonts.body(_darkColorScheme.onSurface),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: AppFonts.subtitle(_darkColorScheme.onPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      cardTheme: CardTheme(
        color: _darkColorScheme.surface,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
