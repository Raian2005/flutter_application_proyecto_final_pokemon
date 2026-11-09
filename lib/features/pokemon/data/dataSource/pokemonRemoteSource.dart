import 'package:flutter_application_proyecto_final_pokemon/core/network/graphqlClient.dart';
import 'package:flutter_application_proyecto_final_pokemon/features/pokemon/data/models/pokemonDto.dart';

class PokemonRemoteSource {
  PokemonRemoteSource(this.client);

  final GraphqlClient client;

  static const _query = r'''
    query GetPokemon($limit: Int!, $offset: Int!) {
      pokemon(limit: $limit, offset: $offset, order_by: {id: asc}) {
        id
        name
        height
        weight
        is_default
        pokemontypes {
          type {
            id
            name
          }
        }
        pokemonabilities {
          is_hidden
          ability {
            id
            name
            abilityeffecttexts(
              where: {language_id: {_eq: 9}}
              limit: 1
            ) {
              effect
            }
          }
        }
        pokemonstats {
          base_stat
          stat {
            name
          }
        }
        pokemonspecy {
          evolution_chain_id
          generation_id
          pokemonegggroups {
            egggroup {
              id
              name
            }
          }
        }
        pokemonforms {
          name
          form_name
          is_default
        }
      }
    }
  ''';

  Future<List<PokemonDto>> fetchPokemons({int limit = 50, int offset = 0}) async {
    final data = await client.query(
      _query,
      variables: {'limit': limit, 'offset': offset},
    );
    final rows = data['pokemon'];
    if (rows is! List) {
      throw StateError('GraphQL no devolvió la colección de Pokémon.');
    }
    return rows
        .whereType<Map>()
        .map((row) => PokemonDto.fromGraphql(_normalize(row)))
        .toList();
  }

  Map<String, dynamic> _normalize(Map row) {
    final pokemon = Map<String, dynamic>.from(row);
    final species = pokemon['pokemonspecy'] is Map
        ? Map<String, dynamic>.from(pokemon['pokemonspecy'])
        : <String, dynamic>{};
    final forms = pokemon['pokemonforms'] is List
        ? pokemon['pokemonforms'] as List
        : const [];
    final form = forms.whereType<Map>().firstWhere(
      (item) => item['is_default'] != true,
      orElse: () => <String, dynamic>{},
    );
    pokemon['types'] = pokemon.remove('pokemontypes') ?? const [];
    final abilities = pokemon.remove('pokemonabilities');
    pokemon['abilities'] = abilities is List ? abilities : const [];
    final eggGroups = species['pokemonegggroups'];
    pokemon['eggGroups'] = eggGroups is List ? eggGroups : const [];
    final stats = pokemon.remove('pokemonstats');
    pokemon['stats'] = stats is List ? stats : const [];
    pokemon['nationalDex'] = pokemon['id'];
    pokemon['regionId'] = species['generation_id'] ?? '';
    pokemon['evolutionIds'] = species['evolution_chain_id'] == null
        ? const []
        : [species['evolution_chain_id'].toString()];
    pokemon['isForma'] = form.isNotEmpty;
    pokemon['forma'] = form['form_name'] ?? form['name'];
    for (final ability in pokemon['abilities'].whereType<Map>()) {
      if (ability['ability'] is Map) {
        final abilityMap = Map<String, dynamic>.from(ability['ability']);
        abilityMap['effects'] =
            abilityMap.remove('abilityeffecttexts') ?? const [];
        ability['ability'] = abilityMap;
      }
    }
    return pokemon;
  }
}
