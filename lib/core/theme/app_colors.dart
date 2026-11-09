import 'package:flutter/material.dart';

/// Paleta base de la Pokédex.
///
/// neutros cálidos tipo papel + un único rojo de acento.
/// El color fuerte lo aportan los tipos de cada Pokémon, no la interfaz.
abstract final class AppColors {
  // Marca
  static const Color brand = Color(0xFFD62F1F);
  static const Color brandOnDark = Color(0xFFFF6A57);

  // Tema claro
  static const Color lightBackground = Color(0xFFF5F4F0);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceMuted = Color(0xFFECEAE4);
  static const Color lightInk = Color(0xFF15151A);
  static const Color lightInkMuted = Color(0xFF5F5F69);
  static const Color lightOutline = Color(0xFFE3E0D8);

  // Tema oscuro
  static const Color darkBackground = Color(0xFF0E0E11);
  static const Color darkSurface = Color(0xFF18181D);
  static const Color darkSurfaceMuted = Color(0xFF24242B);
  static const Color darkInk = Color(0xFFF3F2EF);
  static const Color darkInkMuted = Color(0xFFA3A3AD);
  static const Color darkOutline = Color(0xFF2E2E36);

  // Estados de conectividad
  static const Color onlineLight = Color(0xFF15803D);
  static const Color offlineLight = Color(0xFF52525B);
  static const Color unavailableLight = Color(0xFFB45309);
  static const Color syncingLight = Color(0xFF1D4ED8);

  static const Color onlineDark = Color(0xFF4ADE80);
  static const Color offlineDark = Color(0xFFA1A1AA);
  static const Color unavailableDark = Color(0xFFFBBF24);
  static const Color syncingDark = Color(0xFF60A5FA);

  // Feedback (trivia, validaciones)
  static const Color success = Color(0xFF15803D);
  static const Color danger = Color(0xFFC81E1E);
}
