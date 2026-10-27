import 'package:flutter/widgets.dart';
import 'package:flutter_application_proyecto_final_pokemon/core/network/graphqlClient.dart';
import 'package:flutter_application_proyecto_final_pokemon/features/pokemon/data/dataSource/pokemonRemoteSource.dart';
import 'package:flutter_application_proyecto_final_pokemon/features/pokemon/data/repositories/pokemonImpRepository.dart';
import 'package:flutter_application_proyecto_final_pokemon/features/pokemon/domain/repositories/pokemonRepository.dart';

PokemonRepository createPokemonRepository() {
  return PokemonImpRepository(PokemonRemoteSource(GraphqlClient()));
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = createPokemonRepository();
  await repository.loadAll();
}
