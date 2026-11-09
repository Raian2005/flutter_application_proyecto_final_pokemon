import 'dart:convert';

import 'package:flutter_application_proyecto_final_pokemon/features/pokemon/domain/entities/Pokemon.dart';
import 'package:http/http.dart' as http;

class PokemonDetailRemoteSource {
  PokemonDetailRemoteSource({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;
  static const _baseUrl = 'https://pokeapi.co/api/v2';

  Future<PokemonDetailData> fetch(Pokemon pokemon) async {
    final id = pokemon.id;
    final pokemonJson = await _get('pokemon/$id');
    final speciesJson = await _get('pokemon-species/$id');

    final typeNames = (pokemonJson['types'] as List? ?? const [])
        .whereType<Map>()
        .map((item) => '${(item['type'] as Map?)?['name'] ?? ''}')
        .where((name) => name.isNotEmpty)
        .toList();
    final relations = await Future.wait(
      typeNames.map((type) async {
        final typeJson = await _get('type/$type');
        return _typeMultipliers(typeJson['damage_relations'] as Map?);
      }),
    );

    final multipliers = <String, double>{};
    for (final relation in relations) {
      for (final entry in relation.entries) {
        multipliers[entry.key] = (multipliers[entry.key] ?? 1) * entry.value;
      }
    }

    final rawMoves = (pokemonJson['moves'] as List? ?? const [])
        .whereType<Map>()
        .expand<DetailMove>((move) {
          final name = '${(move['move'] as Map?)?['name'] ?? ''}';
          final moveUrl = '${(move['move'] as Map?)?['url'] ?? ''}';
          final details = (move['version_group_details'] as List? ?? const []);
          return details.whereType<Map>().map(
            (detail) => DetailMove(
              name: name,
              url: moveUrl,
              method: '${(detail['move_learn_method'] as Map?)?['name'] ?? ''}',
              level: _int(detail['level_learned_at']),
              versionGroup:
                  '${(detail['version_group'] as Map?)?['name'] ?? ''}',
              generation: _generationFromVersion(
                '${(detail['version_group'] as Map?)?['name'] ?? ''}',
              ),
            ),
          );
        })
        .toList();
    final moveDetails = await _loadMoveDetails(rawMoves);
    final moves = <DetailMove>[];
    final seenMoves = <String>{};
    for (final move in moveDetails) {
      final key = '${move.name}|${move.method}|${move.generation}';
      if (seenMoves.add(key)) moves.add(move);
    }

    return PokemonDetailData(
      pokemon: pokemon,
      abilities: (pokemonJson['abilities'] as List? ?? const [])
          .whereType<Map>()
          .map(
            (item) => DetailAbility(
              name: '${(item['ability'] as Map?)?['name'] ?? ''}',
              hidden: item['is_hidden'] == true,
            ),
          )
          .toList(),
      types: typeNames,
      height: _int(pokemonJson['height']),
      weight: _int(pokemonJson['weight']),
      eggGroups: (speciesJson['egg_groups'] as List? ?? const [])
          .whereType<Map>()
          .map((item) => '${item['name'] ?? ''}')
          .toList(),
      evolutions: await _fetchEvolutions(
        speciesJson['evolution_chain'] as Map?,
      ),
      alternativeForms: _alternativeForms(speciesJson, id),
      multipliers: multipliers,
      moves: moves,
      generations: moves.map((move) => move.generation).toSet().toList()
        ..sort(),
    );
  }

  static List<DetailEvolution> _alternativeForms(
    Map<String, dynamic> species,
    String currentId,
  ) {
    final varieties = species['varieties'];
    if (varieties is! List) return const [];

    final forms = <DetailEvolution>[];
    final seenIds = <String>{currentId};
    for (final variety in varieties.whereType<Map>()) {
      if (variety['is_default'] == true) continue;
      final pokemon = variety['pokemon'];
      if (pokemon is! Map) continue;

      final url = '${pokemon['url'] ?? ''}';
      final formId = RegExp(r'/(\d+)/?$').firstMatch(url)?.group(1);
      if (formId == null || !seenIds.add(formId)) continue;

      final name = '${pokemon['name'] ?? ''}';
      forms.add(
        DetailEvolution(id: formId, name: name, condition: _formLabel(name)),
      );
    }
    return forms;
  }

  static String _formLabel(String name) {
    final normalized = name.toLowerCase();
    for (final region in ['alola', 'galar', 'hisui', 'paldea']) {
      if (normalized.endsWith('-$region')) {
        return 'Forma ${region[0].toUpperCase()}${region.substring(1)}';
      }
    }
    if (normalized.contains('-mega')) return 'Megaforma';
    if (normalized.contains('-gigantamax')) return 'Gigamax';
    return 'Forma alternativa';
  }

  Future<List<DetailMove>> _loadMoveDetails(List<DetailMove> moves) async {
    final uniqueUrls = moves
        .map((move) => move.url)
        .where((url) => url.isNotEmpty)
        .toSet();
    final details = <String, Map<String, dynamic>>{};
    await Future.wait(
      uniqueUrls.map((url) async {
        details[url] = await _getUrl(url);
      }),
    );
    return moves.map((move) {
      final detail = details[move.url];
      final type = '${(detail?['type'] as Map?)?['name'] ?? 'normal'}';
      final category =
          '${(detail?['damage_class'] as Map?)?['name'] ?? 'status'}';
      return move.copyWith(type: type, category: category);
    }).toList();
  }

  Future<List<DetailEvolution>> _fetchEvolutions(Map? chainReference) async {
    final url = '${chainReference?['url'] ?? ''}';
    if (url.isEmpty) return const [];
    final chain = await _getUrl(url);
    final result = <DetailEvolution>[];

    void addNode(Map node) {
      final species = node['species'] as Map?;
      final speciesUrl = '${species?['url'] ?? ''}';
      final id = RegExp(r'/(\d+)/?$').firstMatch(speciesUrl)?.group(1);
      if (id != null && species != null) {
        final details = node['evolution_details'] as List?;
        result.add(
          DetailEvolution(
            id: id,
            name: '${species['name'] ?? ''}',
            condition: _evolutionCondition(details),
          ),
        );
      }

      for (final next in (node['evolves_to'] as List? ?? const [])) {
        if (next is Map) addNode(next);
      }
    }

    final root = chain['chain'];
    if (root is Map) addNode(root);
    return result;
  }

  static String _evolutionCondition(List? details) {
    final detail = details?.whereType<Map>().isNotEmpty == true
        ? details!.whereType<Map>().first
        : null;
    if (detail == null) return 'Evolución';
    final level = detail['min_level'];
    if (level != null) return 'Nivel $level';
    final item = detail['item'] as Map?;
    if (item != null) return 'Usa ${item['name']}';
    final trigger = detail['trigger'] as Map?;
    return trigger == null ? 'Evolución' : 'Por ${trigger['name']}';
  }

  Future<Map<String, dynamic>> _get(String path) => _getUrl('$_baseUrl/$path');

  Future<Map<String, dynamic>> _getUrl(String url) async {
    final response = await _client
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 15));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('No se pudo cargar el detalle del Pokémon.');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map) throw const FormatException('Respuesta inválida.');
    return Map<String, dynamic>.from(decoded);
  }

  static Map<String, double> _typeMultipliers(Map? relations) {
    final result = <String, double>{};
    if (relations == null) return result;
    for (final item in relations['double_damage_from'] as List? ?? const []) {
      if (item is Map) result['${item['name']}'] = 2;
    }
    for (final item in relations['half_damage_from'] as List? ?? const []) {
      if (item is Map) result['${item['name']}'] = 0.5;
    }
    for (final item in relations['no_damage_from'] as List? ?? const []) {
      if (item is Map) result['${item['name']}'] = 0;
    }
    return result;
  }

  static int _int(dynamic value) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? 0;

  static int _generationFromVersion(String version) {
    final match = RegExp(
      r'^(red-blue|yellow|gold-silver|crystal|ruby-sapphire|emerald|firered-leafgreen|diamond-pearl|platinum|heartgold-soulsilver|black-white|colosseum|xd|black-2-white-2|x-y|omega-ruby-alpha-sapphire|sun-moon|ultra-sun-ultra-moon|lets-go-pikachu-lets-go-eevee|sword-shield|the-isle-of-armor|the-crown-tundra|scarlet-violet)',
    ).firstMatch(version);
    if (match == null) return 9;
    const starts = <String>[
      'red-blue',
      'yellow',
      'gold-silver',
      'crystal',
      'ruby-sapphire',
      'emerald',
      'firered-leafgreen',
      'diamond-pearl',
      'platinum',
      'heartgold-soulsilver',
      'black-white',
      'colosseum',
      'xd',
      'black-2-white-2',
      'x-y',
      'omega-ruby-alpha-sapphire',
      'sun-moon',
      'ultra-sun-ultra-moon',
      'lets-go-pikachu-lets-go-eevee',
      'sword-shield',
      'the-isle-of-armor',
      'the-crown-tundra',
      'scarlet-violet',
    ];
    final index = starts.indexOf(match.group(1)!);
    if (index <= 1) return 1;
    if (index <= 3) return 2;
    if (index <= 6) return 3;
    if (index <= 9) return 4;
    if (index <= 13) return 5;
    if (index <= 14) return 6;
    if (index <= 16) return 7;
    if (index <= 19) return 8;
    return 9;
  }
}

class PokemonDetailData {
  const PokemonDetailData({
    required this.pokemon,
    required this.abilities,
    required this.types,
    required this.height,
    required this.weight,
    required this.eggGroups,
    required this.evolutions,
    required this.alternativeForms,
    required this.multipliers,
    required this.moves,
    required this.generations,
  });

  final Pokemon pokemon;
  final List<DetailAbility> abilities;
  final List<String> types;
  final int height;
  final int weight;
  final List<String> eggGroups;
  final List<DetailEvolution> evolutions;
  final List<DetailEvolution> alternativeForms;
  final Map<String, double> multipliers;
  final List<DetailMove> moves;
  final List<int> generations;
}

class DetailAbility {
  const DetailAbility({required this.name, required this.hidden});
  final String name;
  final bool hidden;
}

class DetailEvolution {
  const DetailEvolution({
    required this.id,
    required this.name,
    required this.condition,
  });
  final String id;
  final String name;
  final String condition;
}

class DetailMove {
  const DetailMove({
    required this.name,
    required this.url,
    required this.method,
    required this.level,
    required this.versionGroup,
    required this.generation,
    this.type = 'normal',
    this.category = 'status',
  });
  final String name;
  final String url;
  final String method;
  final int level;
  final String versionGroup;
  final int generation;
  final String type;
  final String category;

  DetailMove copyWith({String? type, String? category}) => DetailMove(
    name: name,
    url: url,
    method: method,
    level: level,
    versionGroup: versionGroup,
    generation: generation,
    type: type ?? this.type,
    category: category ?? this.category,
  );
}
