import 'package:flutter_application_proyecto_final_pokemon/features/pokemon/domain/entities/Estadisticas.dart';
import 'package:flutter_application_proyecto_final_pokemon/features/pokemon/domain/entities/GrupoHuevo.dart';
import 'package:flutter_application_proyecto_final_pokemon/features/pokemon/domain/entities/Habilidad.dart';
import 'package:flutter_application_proyecto_final_pokemon/features/pokemon/domain/entities/Pokemon.dart';
import 'package:flutter_application_proyecto_final_pokemon/features/pokemon/domain/entities/Tipo.dart';

class PokemonDto {
  final Map<String, dynamic> value;

  const PokemonDto(this.value);

  factory PokemonDto.fromGraphql(Map<String, dynamic> json) => PokemonDto(json);

  factory PokemonDto.fromJson(Map<String, dynamic> json) => PokemonDto(json);

  Map<String, dynamic> toJson() => value;

  Pokemon toDomain() {
    final id = '${value['id']}';
    final types = _list(value['types']).map((item) {
      final type = _map(item['type']);
      return Tipo(nombre: '${type['name'] ?? ''}', id: '${type['id'] ?? ''}');
    }).toList();
    final abilities = _list(value['abilities']).map((item) {
      final ability = _map(item['ability']);
      final effects = _list(ability['effects']);
      return Habilidad(
        nombre: '${ability['name'] ?? ''}',
        id: '${ability['id'] ?? ''}',
        descripcion: effects.isEmpty
            ? ''
            : '${_map(effects.first)['effect'] ?? ''}',
        isOculta: item['is_hidden'] == true,
      );
    }).toList();
    final eggs = _list(value['eggGroups']).map((item) {
      final egg = _map(item['egg_group']);
      return GrupoHuevo(
        nombre: '${egg['name'] ?? ''}',
        id: '${egg['id'] ?? ''}',
      );
    }).toList();
    final stats = <String, int>{
      for (final item in _list(value['stats']))
        '${_map(item['stat'])['name']}': _number(item['base_stat']),
    };

    return Pokemon(
      id: id,
      name: '${value['name'] ?? ''}',
      nationalDex: _number(value['nationalDex']),
      arte: _image(id, large: true),
      sprite: _image(id),
      shinySprite: _image(id, shiny: true),
      shinyArte: _image(id, shiny: true, large: true),
      peso: '${value['weight'] ?? 0}',
      altura: '${value['height'] ?? 0}',
      tipos: types,
      habilidades: abilities,
      gruposHuevos: eggs,
      evoId: _list(value['evolutionIds'])
          .map((item) => item?.toString())
          .toList(),
      regionId: '${value['regionId'] ?? ''}',
      isFavorito: value['isFavorito'] == true,
      stats: Estadisticas(
        nombre: '${value['name'] ?? ''}',
        hp: stats['hp'] ?? 0,
        ataque: stats['attack'] ?? 0,
        defensa: stats['defense'] ?? 0,
        ataqueEspecial: stats['special-attack'] ?? 0,
        defensaEspecial: stats['special-defense'] ?? 0,
        velocidad: stats['speed'] ?? 0,
      ),
      isForma: value['isForma'] == true,
      forma: value['forma']?.toString(),
    );
  }

  static List<dynamic> _list(dynamic value) => value is List ? value : const [];

  static Map<String, dynamic> _map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

  static int _number(dynamic value) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? 0;

  static String _image(String id, {bool shiny = false, bool large = false}) {
    final suffix = shiny ? '-shiny' : '';
    final folder = large
        ? 'other/official-artwork'
        : 'versions/generation-v/black-white';
    final file = large
        ? 'official-artwork$suffix.png'
        : (shiny ? 'front_shiny.png' : 'front_default.png');
    return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$folder/$id/$file';
  }
}
