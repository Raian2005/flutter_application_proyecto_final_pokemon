import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_proyecto_final_pokemon/core/theme/pokemon_colors.dart';
import 'package:flutter_application_proyecto_final_pokemon/features/pokemon/data/dataSource/pokemon_detail_remote_source.dart';
import 'package:flutter_application_proyecto_final_pokemon/features/pokemon/domain/entities/Pokemon.dart';

class PokemonDetailPage extends StatefulWidget {
  const PokemonDetailPage({super.key, required this.pokemon});
  final Pokemon pokemon;

  @override
  State<PokemonDetailPage> createState() => _PokemonDetailPageState();
}

class _PokemonDetailPageState extends State<PokemonDetailPage> {
  final _source = PokemonDetailRemoteSource();
  PokemonDetailData? _data;
  Object? _error;
  _ImageView _imageView = _ImageView.art;
  int? _generation;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await _source.fetch(widget.pokemon);
      if (!mounted) return;
      setState(() {
        _data = data;
        _generation = data.generations.isEmpty ? null : data.generations.last;
      });
    } catch (error) {
      if (mounted) setState(() => _error = error);
    }
  }

  String _title(String value) => value
      .split('-')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');

  @override
  Widget build(BuildContext context) {
    final pokemon = widget.pokemon;
    return Scaffold(
      appBar: AppBar(title: Text(_title(pokemon.name))),
      body: _error != null
          ? _ErrorState(
              onRetry: () {
                setState(() => _error = null);
                _load();
              },
            )
          : _data == null
          ? const Center(child: CircularProgressIndicator())
          : _DetailBody(
              data: _data!,
              imageView: _imageView,
              onImageChanged: (value) => setState(() => _imageView = value),
              title: _title,
              generation: _generation,
              onGenerationChanged: (value) =>
                  setState(() => _generation = value),
            ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.data,
    required this.imageView,
    required this.onImageChanged,
    required this.title,
    required this.generation,
    required this.onGenerationChanged,
  });

  final PokemonDetailData data;
  final _ImageView imageView;
  final ValueChanged<_ImageView> onImageChanged;
  final String Function(String) title;
  final int? generation;
  final ValueChanged<int?> onGenerationChanged;

  @override
  Widget build(BuildContext context) {
    final pokemon = data.pokemon;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        _HeroPanel(
          pokemon: pokemon,
          types: data.types,
          imageView: imageView,
          onImageChanged: onImageChanged,
          title: title,
        ),
        const SizedBox(height: 18),
        _Section(
          title: 'Información básica',
          child: _BasicInfo(data: data, title: title),
        ),
        const SizedBox(height: 14),
        _Section(
          title: 'Habilidades',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: data.abilities
                .map(
                  (ability) => Chip(
                    label: Text(
                      '${title(ability.name)}${ability.hidden ? ' (oculta)' : ''}',
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 14),
        _Section(
          title: 'Evoluciones',
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: data.evolutions
                .map(
                  (evolution) => ActionChip(
                    avatar: CachedNetworkImage(
                      imageUrl:
                          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${evolution.id}.png',
                      width: 34,
                      height: 34,
                    ),
                    label: Text(
                      '${title(evolution.name)} · ${evolution.condition}',
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PokemonDetailPage(
                          pokemon: _evolutionPokemon(data.pokemon, evolution),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        if (data.alternativeForms.isNotEmpty) ...[
          const SizedBox(height: 14),
          _Section(
            title: 'Formas alternativas',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: data.alternativeForms
                  .map(
                    (form) => ActionChip(
                      avatar: CachedNetworkImage(
                        imageUrl:
                            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${form.id}.png',
                        width: 34,
                        height: 34,
                      ),
                      label: Text(title(form.name)),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PokemonDetailPage(
                            pokemon: _evolutionPokemon(data.pokemon, form),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
        const SizedBox(height: 14),
        _Section(
          title: 'Debilidades, resistencias e inmunidades',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RelationRow(
                label: 'Débil a',
                values: _relations(data, (value) => value > 1),
                title: title,
              ),
              _RelationRow(
                label: 'Resiste',
                values: _relations(data, (value) => value > 0 && value < 1),
                title: title,
              ),
              _RelationRow(
                label: 'Inmune a',
                values: _relations(data, (value) => value == 0),
                title: title,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _Section(
          title: 'Movimientos',
          child: _MovesTable(
            data: data,
            title: title,
            generation: generation,
            onGenerationChanged: onGenerationChanged,
          ),
        ),
      ],
    );
  }

  static List<String> _relations(
    PokemonDetailData data,
    bool Function(double) test,
  ) => data.multipliers.entries
      .where((entry) => test(entry.value))
      .map((entry) => entry.key)
      .toList();

  static Pokemon _evolutionPokemon(Pokemon source, DetailEvolution evolution) {
    return Pokemon(
      id: evolution.id,
      name: evolution.name,
      nationalDex: int.tryParse(evolution.id) ?? 0,
      arte:
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/${evolution.id}.png',
      sprite:
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${evolution.id}.png',
      shinySprite:
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/${evolution.id}.png',
      shinyArte:
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/shiny/${evolution.id}.png',
      peso: '0',
      altura: '0',
      tipos: const [],
      habilidades: const [],
      gruposHuevos: const [],
      evoId: const [],
      regionId: source.regionId,
      isFavorito: false,
      stats: source.stats,
      isForma: false,
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({
    required this.pokemon,
    required this.types,
    required this.imageView,
    required this.onImageChanged,
    required this.title,
  });
  final Pokemon pokemon;
  final List<String> types;
  final _ImageView imageView;
  final ValueChanged<_ImageView> onImageChanged;
  final String Function(String) title;

  @override
  Widget build(BuildContext context) {
    final color = PokemonColors.getTypeColor(
      types.isEmpty ? 'normal' : types.first,
    );
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(
            '#${pokemon.id.padLeft(4, '0')}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            title(pokemon.name),
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          SizedBox(
            height: 210,
            child: CachedNetworkImage(
              imageUrl: switch (imageView) {
                _ImageView.art => pokemon.arte,
                _ImageView.sprite => pokemon.sprite,
                _ImageView.shinyArt => pokemon.shinyArte,
                _ImageView.shinySprite => pokemon.shinySprite,
              },
              fit: BoxFit.contain,
              errorWidget: (_, _, _) =>
                  const Icon(Icons.catching_pokemon, size: 90),
            ),
          ),
          SegmentedButton<_ImageView>(
            segments: const [
              ButtonSegment(value: _ImageView.art, label: Text('Arte')),
              ButtonSegment(value: _ImageView.sprite, label: Text('Sprite')),
              ButtonSegment(
                value: _ImageView.shinyArt,
                label: Text('Arte shiny'),
              ),
              ButtonSegment(
                value: _ImageView.shinySprite,
                label: Text('Sprite shiny'),
              ),
            ],
            selected: {imageView},
            onSelectionChanged: (selection) => onImageChanged(selection.first),
          ),
          Wrap(
            spacing: 8,
            children: types
                .map(
                  (type) => Chip(
                    label: Text(title(type)),
                    backgroundColor: PokemonColors.getTypeColor(type),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _BasicInfo extends StatelessWidget {
  const _BasicInfo({required this.data, required this.title});
  final PokemonDetailData data;
  final String Function(String) title;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _InfoTile(
          label: 'Peso',
          value: '${(data.weight / 10).toStringAsFixed(1)} kg',
        ),
        _InfoTile(
          label: 'Altura',
          value: '${(data.height / 10).toStringAsFixed(1)} m',
        ),
        _InfoTile(
          label: 'Grupos huevo',
          value: data.eggGroups.map(title).join(', '),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 145,
    child: Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    ),
  );
}

class _RelationRow extends StatelessWidget {
  const _RelationRow({
    required this.label,
    required this.values,
    required this.title,
  });
  final String label;
  final List<String> values;
  final String Function(String) title;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 92,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Text(
            values.isEmpty ? 'Ninguna' : values.map(title).join(' · '),
          ),
        ),
      ],
    ),
  );
}

class _MovesTable extends StatelessWidget {
  const _MovesTable({
    required this.data,
    required this.title,
    required this.generation,
    required this.onGenerationChanged,
  });
  final PokemonDetailData data;
  final String Function(String) title;
  final int? generation;
  final ValueChanged<int?> onGenerationChanged;

  @override
  Widget build(BuildContext context) {
    final moves =
        data.moves
            .where(
              (move) => generation == null || move.generation == generation,
            )
            .toList()
          ..sort((a, b) {
            int category(String method) => method == 'level-up'
                ? 0
                : method == 'machine'
                ? 1
                : 2;
            final compare = category(a.method).compareTo(category(b.method));
            return compare == 0 ? a.level.compareTo(b.level) : compare;
          });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<int>(
          initialValue: generation,
          decoration: const InputDecoration(labelText: 'Generación'),
          items: data.generations
              .map(
                (value) => DropdownMenuItem(
                  value: value,
                  child: Text('Generación $value'),
                ),
              )
              .toList(),
          onChanged: onGenerationChanged,
        ),
        const SizedBox(height: 12),
        if (moves.isEmpty)
          const Text('No hay movimientos para esta generación.'),
        if (moves.isNotEmpty)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Movimiento')),
                DataColumn(label: Text('Cómo lo aprende')),
                DataColumn(label: Text('Nivel')),
                DataColumn(label: Text('Tipo')),
                DataColumn(label: Text('Clase')),
              ],
              rows: moves
                  .map(
                    (move) => DataRow(
                      cells: [
                        DataCell(Text(title(move.name))),
                        DataCell(Text(_method(move.method))),
                        DataCell(
                          Text(
                            move.method == 'level-up' ? '${move.level}' : '-',
                          ),
                        ),
                        DataCell(
                          Chip(
                            label: Text(title(move.type)),
                            backgroundColor: PokemonColors.getTypeColor(
                              move.type,
                            ),
                          ),
                        ),
                        DataCell(Text(_category(move.category))),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }

  String _method(String method) {
    if (method == 'level-up') return 'Nivel';
    if (method == 'machine') return 'MT';
    if (method == 'egg') return 'Huevo';
    return title(method);
  }

  String _category(String category) {
    if (category == 'physical') return 'Físico';
    if (category == 'special') return 'Especial';
    return 'Estado';
  }
}

enum _ImageView { art, sprite, shinyArt, shinySprite }

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    ),
  );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('No se pudo cargar el detalle.'),
        const SizedBox(height: 8),
        FilledButton(onPressed: onRetry, child: const Text('Reintentar')),
      ],
    ),
  );
}
