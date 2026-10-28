import 'package:flutter_application_proyecto_final_pokemon/features/pokemon/data/dataSource/pokemonRemoteSource.dart';
import 'package:flutter_application_proyecto_final_pokemon/features/pokemon/domain/entities/Pokemon.dart';
import 'package:flutter_application_proyecto_final_pokemon/features/pokemon/domain/repositories/pokemonRepository.dart';

class PokemonImpRepository implements PokemonRepository {
  PokemonImpRepository(this.remote);

  final PokemonRemoteSource remote;

  @override
  Future<List<Pokemon>> loadAll() async {
    final remotePokemon = await remote.fetchAll();
    if (remotePokemon.isEmpty) {
      throw StateError('GraphQL devolvió cero Pokémon.');
    }
    return remotePokemon.map((item) => item.toDomain()).toList();
  }
}
