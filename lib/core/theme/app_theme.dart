import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color _ink = Color(0xFF0B1B34);
  static const Color _blue = Color(0xFF1F3A60);
  static const Color _teal = Color(0xFFC9A760);
  static const Color _surface = Color(0xFFF6F2EA);

  static const Color _darkBg = Color(0xFF0A0F1A);
  static const Color _darkSurface = Color(0xFF111827);
  static const Color _darkInk = Color(0xFFF0F4FF);
  static const Color _darkBlue = Color(0xFF4A90D9);
  static const Color _darkTeal = Color(0xFFD4A853);

  static const double radiusCard = 24.0;
  static const double radiusButton = 14.0;
  static const double radiusInput = 14.0;

  static ThemeData get lightTheme => _build(Brightness.light);
  static ThemeData get darkTheme => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final Color ink = isDark ? _darkInk : _ink;
    final Color primary = isDark ? _darkBlue : _blue;
    final Color secondary = isDark ? _darkTeal : _teal;
    final Color surface = isDark ? _darkSurface : _surface;
    final Color scaffoldBg = isDark ? _darkBg : const Color(0xFFF2F2F7);

    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
      surface: surface,
    ).copyWith(
      primary: primary,
      secondary: secondary,
      surface: surface,
      onSurface: ink,
    );

    final TextTheme textTheme = GoogleFonts.interTextTheme().copyWith(
      displaySmall: GoogleFonts.inter(fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: -1.5, color: ink),
      titleLarge: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.5, color: ink),
      titleMedium: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: -0.3, color: ink),
      bodyLarge: GoogleFonts.inter(fontSize: 17, height: 1.5, letterSpacing: -0.2, color: ink),
      bodyMedium: GoogleFonts.inter(fontSize: 15, height: 1.45, letterSpacing: -0.15, color: ink.withValues(alpha: 0.75)),
      labelSmall: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.2, color: ink.withValues(alpha: 0.45)),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffoldBg,
      textTheme: textTheme,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? Colors.white.withValues(alpha: 0.07) : Colors.white.withValues(alpha: 0.92),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: TextStyle(
          color: isDark ? const Color(0xFF8E9BB5) : const Color(0xFF6B7280),
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(color: isDark ? const Color(0xFF4A5568) : const Color(0xFF9CA3AF)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusInput), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: isDark ? BorderSide(color: Colors.white.withValues(alpha: 0.08), width: 0.5) : BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: BorderSide(color: primary.withValues(alpha: 0.5), width: 1.0),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusButton)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0, centerTitle: false),
      cardTheme: CardThemeData(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white.withValues(alpha: 0.85),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusCard)),
      ),
    );
  }
}
