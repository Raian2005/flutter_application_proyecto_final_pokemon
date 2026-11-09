// Escala de espaciado y radios.
abstract final class Gap {
  static const double xxs = 2;
  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 24;
  static const double xxl = 32;

  // Margen horizontal de las pantallas.
  static const double page = 20;
}

abstract final class Radii {
  static const double chip = 999;
  static const double field = 16;
  static const double card = 24;
  static const double sheet = 32;
}

// Objetivo táctil mínimo
const double kMinTapTarget = 48;
