import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application_proyecto_final_pokemon/core/theme/app_text.dart';
import 'package:flutter_application_proyecto_final_pokemon/core/theme/pokemon_colors.dart';
import 'package:flutter_application_proyecto_final_pokemon/features/pokemon/domain/entities/Pokemon.dart';

class PokemonCard extends StatelessWidget {
  const PokemonCard({
    super.key,
    required this.pokemon,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  final Pokemon pokemon;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  String get _formattedDexNumber {
    final num = int.tryParse(pokemon.id) ?? pokemon.nationalDex;
    return '#${num.toString().padLeft(4, '0')}';
  }

  String get _formattedName {
    if (pokemon.name.isEmpty) return '';
    return pokemon.name[0].toUpperCase() + pokemon.name.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final primaryType = pokemon.tipos.isNotEmpty ? pokemon.tipos.first.nombre : 'normal';
    final cardBgColor = PokemonColors.getTypeColor(primaryType);

    return Semantics(
      button: true,
      label: '$_formattedName, número $_formattedDexNumber',
      child: Material(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              // 1. Marca de agua de la Pokébola en el fondo
              Positioned(
                right: -20,
                bottom: -20,
                child: Opacity(
                  opacity: 0.18,
                  child: Icon(
                    Icons.catching_pokemon,
                    size: 115,
                    color: PokemonColors.getTypeBorderColor(primaryType),
                  ),
                ),
              ),

              // 2. Imagen del Pokémon (Hero Animation + Cached Network Image)
              Positioned(
                right: 8,
                bottom: 8,
                child: Hero(
                  tag: 'pokemon-image-${pokemon.id}',
                  child: CachedNetworkImage(
                    imageUrl: pokemon.arte.isNotEmpty ? pokemon.arte : pokemon.sprite,
                    height: 85,
                    width: 85,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const SizedBox(
                      width: 25,
                      height: 25,
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                    ),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.catching_pokemon,
                      size: 50,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ),

              // 3. Textos (Número, Nombre y Chips de Tipos)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 40, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Número de Dex (#0025) en JetBrains Mono
                    Text(
                      _formattedDexNumber,
                      style: AppText.mono(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.black.withValues(alpha: 0.40),
                      ),
                    ),
                    const SizedBox(height: 2),

                    // Nombre del Pokémon (Manrope extra bold w800)
                    Text(
                      _formattedName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: const Color(0xFF15151A),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Chips de Tipos (fondo blanco + punto de color + texto oscuro)
                    Wrap(
                      direction: Axis.vertical,
                      spacing: 4,
                      children: pokemon.tipos.map((t) {
                        final typeColor = PokemonColors.getTypeBorderColor(t.nombre);
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.90),
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: typeColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                t.nombre.isNotEmpty
                                    ? t.nombre[0].toUpperCase() + t.nombre.substring(1).toLowerCase()
                                    : '',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF15151A),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              // 4. Botón de Favorito
              Positioned(
                top: 4,
                right: 4,
                child: IconButton(
                  icon: Icon(
                    pokemon.isFavorito ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: pokemon.isFavorito ? const Color(0xFFD62F1F) : const Color(0xFF15151A).withValues(alpha: 0.40),
                    size: 22,
                  ),
                  onPressed: onFavoriteToggle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}