import 'package:flutter/material.dart';

class PokemonColors {
  /// Devuelve el color de acento/borde fuerte para cada tipo
  static Color getTypeBorderColor(String typeName) {
    switch (typeName.toLowerCase().trim()) {
      case 'normal':
        return const Color(0xFFA8A77A);
      case 'fuego':
      case 'fire':
        return const Color(0xFFEE8130);
      case 'agua':
      case 'water':
        return const Color(0xFF6390F0);
      case 'eléctrico':
      case 'electrico':
      case 'electric':
        return const Color(0xFFF7D02C);
      case 'planta':
      case 'grass':
        return const Color(0xFF7AC74C);
      case 'hielo':
      case 'ice':
        return const Color(0xFF96D9D6);
      case 'lucha':
      case 'fighting':
        return const Color(0xFFC22E28);
      case 'veneno':
      case 'poison':
        return const Color(0xFFA33EA1);
      case 'tierra':
      case 'ground':
        return const Color(0xFFE2BF65);
      case 'volador':
      case 'flying':
        return const Color(0xFFA98FF3);
      case 'psíquico':
      case 'psiquico':
      case 'psychic':
        return const Color(0xFFF95587);
      case 'bicho':
      case 'bug':
        return const Color(0xFFA6B91A);
      case 'roca':
      case 'rock':
        return const Color(0xFFB6A136);
      case 'fantasma':
      case 'ghost':
        return const Color(0xFF735797);
      case 'dragón':
      case 'dragon':
        return const Color(0xFF6F35FC);
      case 'siniestro':
      case 'dark':
        return const Color(0xFF705746);
      case 'acero':
      case 'steel':
        return const Color(0xFFB7B7CE);
      case 'hada':
      case 'fairy':
        return const Color(0xFFD685AD);
      default:
        return const Color(0xFFA8A77A);
    }
  }

  /// Devuelve el color de fondo suave para las tarjetas según el tipo
  static Color getTypeColor(String typeName) {
    final baseColor = getTypeBorderColor(typeName);
    return Color.alphaBlend(
      baseColor.withValues(alpha: 0.18),
      const Color(0xFFF5F4F0),
    );
  }
}
