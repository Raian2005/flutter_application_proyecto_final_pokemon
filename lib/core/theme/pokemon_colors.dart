import 'package:flutter/material.dart';

class PokemonColors {
  /// Devuelve el color de fondo suave para las tarjetas según el tipo
  static Color getTypeColor(String typeName) {
    switch (typeName.toLowerCase().trim()) {
      case 'normal':
        return const Color(0xFFD6D6BD);
      case 'fuego':
      case 'fire':
        return const Color(0xFFFDC28A);
      case 'agua':
      case 'water':
        return const Color(0xFF99C0FF);
      case 'eléctrico':
      case 'electrico':
      case 'electric':
        return const Color(0xFFFFE675);
      case 'planta':
      case 'grass':
        return const Color(0xFFB4E69B);
      case 'hielo':
      case 'ice':
        return const Color(0xFFA8ECE7);
      case 'lucha':
      case 'fighting':
        return const Color(0xFFEA9B96);
      case 'veneno':
      case 'poison':
        return const Color(0xFFE1A4E1);
      case 'tierra':
      case 'ground':
        return const Color(0xFFF0D896);
      case 'volador':
      case 'flying':
        return const Color(0xFFC6B7F5);
      case 'psíquico':
      case 'psiquico':
      case 'psychic':
        return const Color(0xFFFFB1C5);
      case 'bicho':
      case 'bug':
        return const Color(0xFFD8EC8A);
      case 'roca':
      case 'rock':
        return const Color(0xFFDCD38C);
      case 'fantasma':
      case 'ghost':
        return const Color(0xFFC7B8DA);
      case 'dragón':
      case 'dragon':
        return const Color(0xFFB6A4FF);
      case 'siniestro':
      case 'dark':
        return const Color(0xFFC2B5AA);
      case 'acero':
      case 'steel':
        return const Color(0xFFD8DEEC);
      case 'hada':
      case 'fairy':
        return const Color(0xFFF8C4DD);
      default:
        return const Color(0xFFD6D6BD);
    }
  }

  /// Devuelve el color de acento/borde fuerte para cada tipo
  static Color getTypeBorderColor(String typeName) {
    switch (typeName.toLowerCase().trim()) {
      case 'normal':
        return const Color(0xFF8A8A67);
      case 'fuego':
      case 'fire':
        return const Color(0xFFE66600);
      case 'agua':
      case 'water':
        return const Color(0xFF386CEB);
      case 'eléctrico':
      case 'electrico':
      case 'electric':
        return const Color(0xFFF7C600);
      case 'planta':
      case 'grass':
        return const Color(0xFF57B92A);
      case 'hielo':
      case 'ice':
        return const Color(0xFF22B8AE);
      case 'lucha':
      case 'fighting':
        return const Color(0xFFB82B24);
      case 'veneno':
      case 'poison':
        return const Color(0xFF903590);
      case 'tierra':
      case 'ground':
        return const Color(0xFFC59529);
      case 'volador':
      case 'flying':
        return const Color(0xFF7651F7);
      case 'psíquico':
      case 'psiquico':
      case 'psychic':
        return const Color(0xFFF03265);
      case 'bicho':
      case 'bug':
        return const Color(0xFF8DA300);
      case 'roca':
      case 'rock':
        return const Color(0xFFA18925);
      case 'fantasma':
      case 'ghost':
        return const Color(0xFF5C457D);
      case 'dragón':
      case 'dragon':
        return const Color(0xFF5B20F8);
      case 'siniestro':
      case 'dark':
        return const Color(0xFF574235);
      case 'acero':
      case 'steel':
        return const Color(0xFF8686A3);
      case 'hada':
      case 'fairy':
        return const Color(0xFFE67793);
      default:
        return const Color(0xFF8A8A67);
    }
  }
}