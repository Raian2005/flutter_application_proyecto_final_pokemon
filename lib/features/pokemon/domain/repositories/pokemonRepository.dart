import 'package:flutter_application_proyecto_final_pokemon/features/pokemon/domain/entities/Pokemon.dart';

abstract interface class PokemonRepository {
  Future<List<Pokemon>> loadAll();
  Future<bool> toggleFavorite(String pokemonId);
  Future<List<Pokemon>> getFavorites();
}