import 'package:flutter_application_proyecto_final_pokemon/features/pokemon/domain/model/Pokemon.dart';

abstract interface class PokemonRepository {
  Future<List<Pokemon>> loadAll();
}
