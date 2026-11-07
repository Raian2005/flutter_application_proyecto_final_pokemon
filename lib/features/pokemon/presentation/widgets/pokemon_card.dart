import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
                  opacity: 0.20,
                  child: Icon(
                    Icons.catching_pokemon,
                    size: 115,
                    color: Colors.white,
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
                    // Número de Dex (#0025)
                    Text(
                      _formattedDexNumber,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black.withValues(alpha: 0.35),
                      ),
                    ),
                    const SizedBox(height: 2),

                    // Nombre del Pokémon
                    Text(
                      _formattedName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black12,
                            offset: Offset(0, 1),
                            blurRadius: 2,
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Chips de Tipos
                    Wrap(
                      direction: Axis.vertical,
                      spacing: 4,
                      children: pokemon.tipos.map((t) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.4),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            t.nombre.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              // 4. Botón de Favorito (Corazón)
              Positioned(
                top: 4,
                right: 4,
                child: IconButton(
                  icon: Icon(
                    pokemon.isFavorito ? Icons.favorite : Icons.favorite_border,
                    color: pokemon.isFavorito ? Colors.redAccent : Colors.white.withValues(alpha: 0.85),
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