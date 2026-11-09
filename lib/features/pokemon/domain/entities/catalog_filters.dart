enum CatalogSort {
  number('Numero'),
  name('Nombre'),
  totalBase('Total base');

  final String label;
  const CatalogSort(this.label);
}

const List<String> kGenerationLabels = ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX'];

class CatalogFilters {
  final String query;
  final Set<String> types;
  final int? generation;
  final CatalogSort sort;
  final bool ascending;

  const CatalogFilters({
    this.query = '',
    this.types = const {},
    this.generation,
    this.sort = CatalogSort.number,
    this.ascending = true,
  });

  bool get hasActiveFilters =>
      types.isNotEmpty || generation != null || sort != CatalogSort.number || !ascending;

  CatalogFilters copyWith({
    String? query,
    Set<String>? types,
    int? generation,
    bool clearGeneration = false,
    CatalogSort? sort,
    bool? ascending,
  }) {
    return CatalogFilters(
      query: query ?? this.query,
      types: types ?? this.types,
      generation: clearGeneration ? null : (generation ?? this.generation),
      sort: sort ?? this.sort,
      ascending: ascending ?? this.ascending,
    );
  }
}

