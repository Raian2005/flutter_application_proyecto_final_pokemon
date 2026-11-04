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
    try {
      final remotePokemon = await remote.fetchAll();
      if (remotePokemon.isNotEmpty){
        await local.insertPokemon(remotePokemon);
      }
    } catch (_){}

    final localPokemon = await local.getCachePokemons();
    if(localPokemon.isEmpty){
      throw StateError('No hay datos de pokemon disponibles ni en remoto ni en local');
    }

    return localPokemon.map((item) => item.toDomain()).toList();
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
