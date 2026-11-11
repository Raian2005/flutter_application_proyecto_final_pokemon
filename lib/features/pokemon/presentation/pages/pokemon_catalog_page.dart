import 'package:flutter/material.dart';
import 'package:flutter_application_proyecto_final_pokemon/core/database/databaseHelper.dart';
import 'package:flutter_application_proyecto_final_pokemon/core/network/graphqlClient.dart';
import 'package:flutter_application_proyecto_final_pokemon/features/pokemon/data/dataSource/pokemonLocalDataSource.dart';
import 'package:flutter_application_proyecto_final_pokemon/features/pokemon/data/dataSource/pokemonRemoteSource.dart';
import 'package:flutter_application_proyecto_final_pokemon/features/pokemon/data/repositories/pokemonImpRepository.dart';
import 'package:flutter_application_proyecto_final_pokemon/features/pokemon/domain/entities/Pokemon.dart';
import 'package:flutter_application_proyecto_final_pokemon/features/pokemon/domain/entities/catalog_filters.dart';
import 'package:flutter_application_proyecto_final_pokemon/features/pokemon/presentation/widgets/filter_sheet.dart';
import 'package:flutter_application_proyecto_final_pokemon/features/pokemon/presentation/widgets/pokemon_card.dart';
import 'package:flutter_application_proyecto_final_pokemon/features/pokemon/presentation/pages/pokemon_detail_page.dart';

class PokemonCatalogPage extends StatefulWidget {
  const PokemonCatalogPage({super.key});

  @override
  State<PokemonCatalogPage> createState() => _PokemonCatalogPageState();
}

class _PokemonCatalogPageState extends State<PokemonCatalogPage> {
  late final PokemonImpRepository _repository;
  final ScrollController _scrollController = ScrollController();

  List<Pokemon> _allPokemons = [];
  CatalogFilters _filters = const CatalogFilters();
  bool _isLoading = true;

  int _displayLimit = 20;

  @override
  void initState() {
    super.initState();
    _repository = PokemonImpRepository(
      remote: PokemonRemoteSource(GraphqlClient()),
      local: PokemonLocalDataSource(DatabaseHelper.instance),
    );

    _scrollController.addListener(_onScroll);
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      final totalFiltered = _filteredPokemonsAll.length;
      if (_displayLimit < totalFiltered) {
        setState(() {
          _displayLimit += 20;
        });
      }
    }
  }

  Future<void> _loadData() async {
    try {
      final list = await _repository.loadAll();
      setState(() {
        _allPokemons = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<Pokemon> get _filteredPokemonsAll {
    var list = _allPokemons.where((p) {
      if (_filters.query.isNotEmpty) {
        final q = _filters.query.toLowerCase();
        final matchName = p.name.toLowerCase().contains(q);
        final matchId = p.id.contains(q);
        if (!matchName && !matchId) return false;
      }

      if (_filters.types.isNotEmpty) {
        final pokemonTypeNames = p.tipos
            .map((t) => t.nombre.toLowerCase())
            .toSet();
        final matchesAllTypes = _filters.types.every(
          (ft) => pokemonTypeNames.contains(ft.toLowerCase()),
        );
        if (!matchesAllTypes) return false;
      }

      if (_filters.generation != null) {
        if (p.regionId != _filters.generation.toString()) return false;
      }

      return true;
    }).toList();

    // Ordenación
    list.sort((a, b) {
      int cmp;
      switch (_filters.sort) {
        case CatalogSort.name:
          cmp = a.name.compareTo(b.name);
          break;
        case CatalogSort.totalBase:
          final totalA =
              a.stats.hp +
              a.stats.ataque +
              a.stats.defensa +
              a.stats.ataqueEspecial +
              a.stats.defensaEspecial +
              a.stats.velocidad;
          final totalB =
              b.stats.hp +
              b.stats.ataque +
              b.stats.defensa +
              b.stats.ataqueEspecial +
              b.stats.defensaEspecial +
              b.stats.velocidad;
          cmp = totalA.compareTo(totalB);
          break;
        case CatalogSort.number:
        default:
          final idA = int.tryParse(a.id) ?? 0;
          final idB = int.tryParse(b.id) ?? 0;
          cmp = idA.compareTo(idB);
          break;
      }
      return _filters.ascending ? cmp : -cmp;
    });

    return list;
  }

  Future<void> _openFilters() async {
    final result = await showFilterSheet(context, initial: _filters);
    if (result != null) {
      setState(() {
        _filters = result;
        _displayLimit =
            20;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final allFiltered = _filteredPokemonsAll;
    final displayedPokemons = allFiltered.take(_displayLimit).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pokédex',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${allFiltered.length} de ${_allPokemons.length} Pokémon guardados',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Búsqueda
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                onChanged: (v) {
                  setState(() {
                    _filters = _filters.copyWith(query: v);
                    _displayLimit = 20;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre o número...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Colors.grey,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ActionChip(
                elevation: 0,
                side: BorderSide(
                  color: _filters.hasActiveFilters
                      ? const Color(0xFFE53935)
                      : Colors.grey.shade300,
                ),
                backgroundColor: _filters.hasActiveFilters
                    ? const Color(0xFFE53935)
                    : Colors.white,
                avatar: Icon(
                  Icons.tune_rounded,
                  size: 18,
                  color: _filters.hasActiveFilters
                      ? Colors.white
                      : Colors.black87,
                ),
                label: Text(
                  'Filtros${_filters.hasActiveFilters ? ' •' : ''}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _filters.hasActiveFilters
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
                onPressed: _openFilters,
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : displayedPokemons.isEmpty
                  ? Center(
                      child: Text(
                        'No se encontraron Pokémon',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : GridView.builder(
                      controller: _scrollController, // Controlador de scroll
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.35,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: displayedPokemons.length,
                      itemBuilder: (context, index) {
                        final pokemon = displayedPokemons[index];
                        return PokemonCard(
                          pokemon: pokemon,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    PokemonDetailPage(pokemon: pokemon),
                              ),
                            );
                          },
                          onFavoriteToggle: () async {
                            final newFav = await _repository.toggleFavorite(
                              pokemon.id,
                            );
                            setState(() {
                              final i = _allPokemons.indexWhere(
                                (p) => p.id == pokemon.id,
                              );
                              if (i != -1) {
                                _allPokemons[i] = Pokemon(
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
                                  isFavorito: newFav,
                                  stats: pokemon.stats,
                                  isForma: pokemon.isForma,
                                  forma: pokemon.forma,
                                );
                              }
                            });
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
