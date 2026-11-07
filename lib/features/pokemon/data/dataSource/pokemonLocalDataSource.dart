import 'dart:convert';
import 'package:flutter_application_proyecto_final_pokemon/core/database/databaseHelper.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_application_proyecto_final_pokemon/features/pokemon/data/models/pokemonDto.dart';

class PokemonLocalDataSource {
  PokemonLocalDataSource(this. _dbHelper);

  final DatabaseHelper _dbHelper;

  Future<void> insertPokemon(List<PokemonDto> pokemons) async {
    final db = await _dbHelper.database;

    await db.transaction((txn) async {
      for (final pokemon in pokemons) {

        final domain = pokemon.toDomain();

        await txn.insert(
          'pokemons',
          {
            'id': pokemon.value['id'].toString(),
            'name': pokemon.value['name'] ?? '',
            'height': pokemon.value['height'] ?? 0,
            'weight': pokemon.value['weight'] ?? 0,
            'hp': domain.stats.hp,
            'attack': domain.stats.ataque,
            'defense': domain.stats.defensa,
            'special_attack': domain.stats.ataqueEspecial,
            'special_defense': domain.stats.defensaEspecial,
            'speed': domain.stats.velocidad,
            'raw_json': jsonEncode(pokemon.value),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
    cachePokemonImages(pokemons);
  }

  Future<List<PokemonDto>> getCachePokemons() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('pokemons');

    if (maps.isEmpty) return [];

    final favoritesIds = await getFavoriteIds();

    return maps.map((map) {
      final jsonString = map['raw_json'] as String;
      final Map<String, dynamic> jsonMap = Map<String, dynamic>.from(jsonDecode(jsonString));

      final pokemonId = jsonMap['id'].toString();
      jsonMap['isFavorito'] = favoritesIds.contains(pokemonId);

      return PokemonDto.fromGraphql(jsonMap);
    }).toList();
  }

  Future<Set<String>> getFavoriteIds() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('favorites');
    return maps.map((m) => m['pokemon_id'].toString()).toSet();
  }

  Future<bool> isFavorite(String pokemonId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'favorites',
      where: 'pokemon_id = ?',
      whereArgs: [pokemonId],
    );
    return maps.isNotEmpty;
  }

  Future<bool> toggleFavorite(String pokemonId) async {
    final db = await _dbHelper.database;
    final isFav = await isFavorite(pokemonId);

    if (isFav) {
      await db.delete(
        'favorites',
        where: 'pokemon_id = ?',
        whereArgs: [pokemonId],
      );

      return false;
    } else {
      await db.insert(
      'favorites',
      {
        'pokemon_id': pokemonId,
        'created_at': DateTime.now().toIso8601String(),
      },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return true;
    }
  }

  Future<void> cachePokemonImages(List<PokemonDto> pokemons) async {
    for (final dto in pokemons) {
      final domain = dto.toDomain();

      if(domain.arte.isNotEmpty){
        try {
          DefaultCacheManager().downloadFile(domain.arte).catchError((_) {});
        } catch (_) {}
      }

      if(domain.sprite.isNotEmpty){
        try {
          DefaultCacheManager().downloadFile(domain.sprite).catchError((_) {});
        } catch (_) {}
      }
    }
  }
}