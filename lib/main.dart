
import 'package:flutter/cupertino.dart';
import 'package:flutter_application_proyecto_final_pokemon/core/database/databaseHelper.dart';
import 'package:flutter_application_proyecto_final_pokemon/core/network/graphqlClient.dart';
import 'package:flutter_application_proyecto_final_pokemon/features/pokemon/data/dataSource/pokemonLocalDataSource.dart';
import 'package:flutter_application_proyecto_final_pokemon/features/pokemon/data/dataSource/pokemonRemoteSource.dart';
import 'package:flutter_application_proyecto_final_pokemon/features/pokemon/data/repositories/pokemonImpRepository.dart';
import 'package:flutter_application_proyecto_final_pokemon/features/pokemon/domain/repositories/pokemonRepository.dart';

PokemonRepository createPokemonRepository() {
  final dbHelper = DatabaseHelper.instance;
  return PokemonImpRepository(
    remote: PokemonRemoteSource(GraphqlClient()),
    local: PokemonLocalDataSource(dbHelper),
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = createPokemonRepository();
  final pokemons = await repository.loadAll();
}
