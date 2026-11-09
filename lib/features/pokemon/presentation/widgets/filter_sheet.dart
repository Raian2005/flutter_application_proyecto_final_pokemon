import 'package:flutter/material.dart';
import 'package:flutter_application_proyecto_final_pokemon/features/pokemon/domain/entities/catalog_filters.dart';
import 'package:flutter_application_proyecto_final_pokemon/features/pokemon/presentation/widgets/type_chip.dart';

Future<CatalogFilters?> showFilterSheet(
  BuildContext context, {
  required CatalogFilters initial,
}) {
  return showModalBottomSheet<CatalogFilters>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) => FilterSheet(initial: initial),
  );
}

class FilterSheet extends StatefulWidget {
  const FilterSheet({super.key, required this.initial});

  final CatalogFilters initial;

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late CatalogFilters _draft = widget.initial;

  // Mapa: Español -> Inglés
  static const Map<String, String> _typeMap = {
    'Normal': 'normal',
    'Fuego': 'fire',
    'Agua': 'water',
    'Eléctrico': 'electric',
    'Planta': 'grass',
    'Hielo': 'ice',
    'Lucha': 'fighting',
    'Veneno': 'poison',
    'Tierra': 'ground',
    'Volador': 'flying',
    'Psíquico': 'psychic',
    'Bicho': 'bug',
    'Roca': 'rock',
    'Fantasma': 'ghost',
    'Dragón': 'dragon',
    'Siniestro': 'dark',
    'Acero': 'steel',
    'Hada': 'fairy',
  };

  void _toggleType(String englishKey) {
    final next = {..._draft.types};
    next.contains(englishKey) ? next.remove(englishKey) : next.add(englishKey);
    setState(() => _draft = _draft.copyWith(types: next));
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Filtros',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Sección 1: Tipo
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tipo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_draft.types.length} seleccionados',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final entry in _typeMap.entries)
                      TypeChip(
                        type: entry.key, // Muestra "Fuego" en pantalla
                        selected: _draft.types.contains(
                          entry.value,
                        ), // Comprueba "fire"
                        onTap: () => _toggleType(entry.value), // Alterna "fire"
                      ),
                  ],
                ),
                const SizedBox(height: 24),

                // Sección 2: Generación
                const Text(
                  'Generación',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Todas'),
                      selected: _draft.generation == null,
                      onSelected: (_) => setState(
                        () => _draft = _draft.copyWith(clearGeneration: true),
                      ),
                    ),
                    for (var g = 1; g <= kGenerationLabels.length; g++)
                      ChoiceChip(
                        label: Text(kGenerationLabels[g - 1]),
                        selected: _draft.generation == g,
                        onSelected: (_) => setState(
                          () => _draft = _draft.copyWith(generation: g),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),

                // Sección 3: Ordenar por
                const Text(
                  'Ordenar por',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SegmentedButton<CatalogSort>(
                  showSelectedIcon: false,
                  segments: [
                    for (final s in CatalogSort.values)
                      ButtonSegment(value: s, label: Text(s.label)),
                  ],
                  selected: {_draft.sort},
                  onSelectionChanged: (v) =>
                      setState(() => _draft = _draft.copyWith(sort: v.first)),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Orden ascendente',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    _draft.ascending ? 'De menor a mayor' : 'De mayor a menor',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  value: _draft.ascending,
                  activeColor: const Color(0xFFE53935),
                  onChanged: (v) =>
                      setState(() => _draft = _draft.copyWith(ascending: v)),
                ),
              ],
            ),
          ),

          // Botones inferiores
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: () => setState(
                        () => _draft = CatalogFilters(query: _draft.query),
                      ),
                      child: const Text(
                        'Limpiar',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(_draft),
                      child: const Text(
                        'Aplicar filtros',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
