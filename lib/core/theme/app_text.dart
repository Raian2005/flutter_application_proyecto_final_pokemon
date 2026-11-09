import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// - Manrope para la interfaz .
// - JetBrains Mono para números de Pokédex y estadísticas
abstract final class AppText {
  static TextTheme textTheme(TextTheme base, Color ink) {
    return TextTheme(
      displayLarge: GoogleFonts.manrope(color: ink),
      displayMedium: GoogleFonts.manrope(color: ink),
      displaySmall: GoogleFonts.manrope(
        fontWeight: FontWeight.w800,
        letterSpacing: -1.2,
        color: ink,
      ),
      headlineLarge: GoogleFonts.manrope(color: ink),
      headlineMedium: GoogleFonts.manrope(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
        color: ink,
      ),
      headlineSmall: GoogleFonts.manrope(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        color: ink,
      ),
      titleLarge: GoogleFonts.manrope(
        fontWeight: FontWeight.w800,
        color: ink,
      ),
      titleMedium: GoogleFonts.manrope(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.2,
        color: ink,
      ),
      titleSmall: GoogleFonts.manrope(
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      bodyLarge: GoogleFonts.manrope(color: ink),
      bodyMedium: GoogleFonts.manrope(color: ink),
      bodySmall: GoogleFonts.manrope(color: ink),
      labelLarge: GoogleFonts.manrope(
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      labelMedium: GoogleFonts.manrope(
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      labelSmall: GoogleFonts.manrope(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
        color: ink,
      ),
    );
  }

  /// Estilo monoespaciado para valores de stats, niveles, etc.
  static TextStyle mono({
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w600,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.jetBrainsMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }
}


