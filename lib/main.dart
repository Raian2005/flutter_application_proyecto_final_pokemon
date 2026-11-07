import 'package:flutter/cupertino.dart';
import 'package:flutter_application_proyecto_final_pokemon/core/database/databaseHelper.dart';
import 'package:flutter_application_proyecto_final_pokemon/core/network/graphqlClient.dart';
import 'package:flutter_application_proyecto_final_pokemon/features/pokemon/data/dataSource/pokemonLocalDataSource.dart';
import 'package:flutter_application_proyecto_final_pokemon/features/pokemon/data/dataSource/pokemonRemoteSource.dart';
import 'package:flutter_application_proyecto_final_pokemon/features/pokemon/data/repositories/pokemonImpRepository.dart';
import 'package:flutter_application_proyecto_final_pokemon/features/pokemon/domain/repositories/pokemonRepository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_proyecto_final_pokemon/features/pokemon/presentation/pages/pokemon_catalog_page.dart';

PokemonRepository createPokemonRepository() {
  final dbHelper = DatabaseHelper.instance;
  return PokemonImpRepository(
    remote: PokemonRemoteSource(GraphqlClient()),
    local: PokemonLocalDataSource(dbHelper),
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PokemonCatalogPage(),
    ),
  );
}
