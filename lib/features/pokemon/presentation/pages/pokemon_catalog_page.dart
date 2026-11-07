import 'package:flutter/material.dart';
import 'package:flutter_application_proyecto_final_pokemon/core/database/databaseHelper.dart';
import 'package:flutter_application_proyecto_final_pokemon/core/network/graphqlClient.dart';
import 'package:flutter_application_proyecto_final_pokemon/features/pokemon/data/dataSource/pokemonLocalDataSource.dart';
import 'package:flutter_application_proyecto_final_pokemon/features/pokemon/data/dataSource/pokemonRemoteSource.dart';
import 'package:flutter_application_proyecto_final_pokemon/features/pokemon/data/repositories/pokemonImpRepository.dart';
import 'package:flutter_application_proyecto_final_pokemon/features/pokemon/domain/entities/Pokemon.dart';
import 'package:flutter_application_proyecto_final_pokemon/features/pokemon/presentation/widgets/pokemon_card.dart';

class PokemonCatalogPage extends StatefulWidget {
  const PokemonCatalogPage({super.key});

  @override
  State<PokemonCatalogPage> createState() => _PokemonCatalogPageState();
}

class _PokemonCatalogPageState extends State<PokemonCatalogPage> {
  late final PokemonImpRepository _repository;
  List<Pokemon> _pokemons = [];
  bool _isLoading = true;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _repository = PokemonImpRepository(
      remote: PokemonRemoteSource(GraphqlClient()),
      local: PokemonLocalDataSource(DatabaseHelper.instance),
    );
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final list = await _repository.loadAll(limit: 50, offset: 0);
      setState(() {
        _pokemons = list;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error cargando pokemons: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text('Pokédex', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando Pokédex...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_errorMessage != null && _pokemons.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
              const SizedBox(height: 12),
              Text(
                'No se pudieron cargar los Pokémon',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_pokemons.isEmpty) {
      return const Center(child: Text('No hay Pokémon disponibles'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.35,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
        itemCount: _pokemons.length,
        itemBuilder: (context, index) {
          final pokemon = _pokemons[index];
          return PokemonCard(
            pokemon: pokemon,
            onTap: () {
              print('Tocado: ${pokemon.name}');
            },
            onFavoriteToggle: () async {
              final newFav = await _repository.toggleFavorite(pokemon.id);
              setState(() {
                _pokemons[index] = Pokemon(
                  id: pokemon.id,
                  name: pokemon.name,
                  nationalDex: pokemon.nationalDex,
                  arte: pokemon.arte,
                  sprite: pokemon.sprite,
                  shinySprite: pokemon.shinySprite,
                  shinyArte: pokemon.shinyArte,
                  peso: pokemon.peso,
                  altura: pokemon.altura,
                  tipos: pokemon.tipos,
                  habilidades: pokemon.habilidades,
                  gruposHuevos: pokemon.gruposHuevos,
                  evoId: pokemon.evoId,
                  regionId: pokemon.regionId,
                  isFavorito: newFav, // 👈 Actualiza el corazón en pantalla
                  stats: pokemon.stats,
                  isForma: pokemon.isForma,
                  forma: pokemon.forma,
                );
              });
            },
          );
        },
      );
  }
}