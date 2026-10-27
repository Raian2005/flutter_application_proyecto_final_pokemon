import 'package:flutter_application_proyecto_final_pokemon/core/network/graphqlClient.dart';
import 'package:flutter_application_proyecto_final_pokemon/features/pokemon/data/models/pokemonDto.dart';

class PokemonRemoteSource {
  PokemonRemoteSource(this.client);

  final GraphqlClient client;

  static const _query = r'''
    query GetPokemon($limit: Int!, $offset: Int!) {
      pokemon_v2_pokemon(limit: $limit, offset: $offset, order_by: {id: asc}) {
        id
        name
        height
        weight
        is_default
        pokemon_v2_pokemontypes { pokemon_v2_type { id name } }
        pokemon_v2_pokemonabilities {
          is_hidden
          pokemon_v2_ability {
            id
            name
            pokemon_v2_abilityeffecttexts(
              where: {language_id: {_eq: 9}}
              limit: 1
            ) { effect }
          }
        }
        pokemon_v2_pokemonstats { base_stat pokemon_v2_stat { name } }
        pokemon_v2_pokemonspecy {
          evolution_chain_id
          generation_id
          pokemon_v2_pokemonegggroups {
            pokemon_v2_egggroup { id name }
          }
        }
        pokemon_v2_pokemonforms { name form_name is_default }
      }
    }
  ''';

  Future<List<PokemonDto>> fetchAll() async {
    const pageSize = 100;
    var offset = 0;
    final result = <PokemonDto>[];

    while (true) {
      final data = await client.query(
        _query,
        variables: {'limit': pageSize, 'offset': offset},
      );
      final rows = data['pokemon_v2_pokemon'];
      if (rows is! List) {
        throw StateError('GraphQL no devolvió la colección de Pokémon.');
      }
      for (final row in rows.whereType<Map>()) {
        result.add(PokemonDto.fromGraphql(_normalize(row)));
      }
      if (rows.length < pageSize) return result;
      offset += pageSize;
    }
  }

  Map<String, dynamic> _normalize(Map row) {
    final pokemon = Map<String, dynamic>.from(row);
    final species = pokemon['pokemon_v2_pokemonspecy'] is Map
        ? Map<String, dynamic>.from(pokemon['pokemon_v2_pokemonspecy'])
        : <String, dynamic>{};
    final forms = pokemon['pokemon_v2_pokemonforms'] is List
        ? pokemon['pokemon_v2_pokemonforms'] as List
        : const [];
    final form = forms.whereType<Map>().firstWhere(
      (item) => item['is_default'] != true,
      orElse: () => <String, dynamic>{},
    );
    pokemon['types'] = pokemon.remove('pokemon_v2_pokemontypes') ?? const [];
    final abilities = pokemon.remove('pokemon_v2_pokemonabilities');
    pokemon['abilities'] = abilities is List ? abilities : const [];
    final eggGroups = species['pokemon_v2_pokemonegggroups'];
    pokemon['eggGroups'] = eggGroups is List ? eggGroups : const [];
    final stats = pokemon.remove('pokemon_v2_pokemonstats');
    pokemon['stats'] = stats is List ? stats : const [];
    for (final type in pokemon['types'].whereType<Map>()) {
      type['type'] = type.remove('pokemon_v2_type');
    }
    pokemon['nationalDex'] = pokemon['id'];
    pokemon['regionId'] = species['generation_id'] ?? '';
    pokemon['evolutionIds'] = species['evolution_chain_id'] == null
        ? const []
        : [species['evolution_chain_id'].toString()];
    pokemon['isForma'] = form.isNotEmpty;
    pokemon['forma'] = form['form_name'] ?? form['name'];
    for (final ability in pokemon['abilities'].whereType<Map>()) {
      final value = ability.remove('pokemon_v2_ability');
      if (value is Map) {
        final abilityMap = Map<String, dynamic>.from(value);
        abilityMap['effects'] =
            abilityMap.remove('pokemon_v2_abilityeffecttexts') ?? const [];
        ability['ability'] = abilityMap;
      }
    }
    return pokemon;
  }
}
