import 'package:flutter_application_proyecto_final_pokemon/features/pokemon/data/dataSource/pokemonRemoteSource.dart';
import 'package:flutter_application_proyecto_final_pokemon/features/pokemon/domain/entities/Pokemon.dart';
import 'package:flutter_application_proyecto_final_pokemon/features/pokemon/domain/repositories/pokemonRepository.dart';
import 'package:flutter_application_proyecto_final_pokemon/features/pokemon/data/dataSource/pokemonLocalDataSource.dart';

class PokemonImpRepository implements PokemonRepository {
  PokemonImpRepository({
    required this.remote,
    required this.local,
  });

  final PokemonRemoteSource remote;
  final PokemonLocalDataSource local;

  @override
  Future<List<Pokemon>> loadAll() async {
    // 1. Si la base de datos local está vacía, se descargan datos desde GrafQL
    final totalCached = await local.getCachedCount();
    if (totalCached < 1000) {
      try {
        final remotePokemon = await remote.fetchPokemons(limit: 2000);
        if (remotePokemon.isNotEmpty) {
          await local.insertPokemon(remotePokemon);
        }
      } catch (e) {
        // Manejo de error si no hay internet en la primera ejecución
      }
    }

    final localPokemon = await local.getCachePokemons();
    if (localPokemon.isEmpty) {
      throw StateError('No hay datos de Pokémon disponibles ni en remoto ni en local.');
    }

    return localPokemon.map((item) => item.toDomain()).toList();
  }

  @override
  Future<int> getTotalCachedCount() async {
    return await local.getCachedCount();
  }

  @override
  Future<bool> toggleFavorite(String pokemonId) async {
    return await local.toggleFavorite(pokemonId);
  }

  @override
  Future<List<Pokemon>> getFavorites() async {
    final allCached = await local.getCachePokemons();
    final domainList = allCached.map((item) => item.toDomain()).toList();
    return domainList.where((p) => p.isFavorito).toList();
  }
}