class TriviaQuestion {
  final String pokemonId;
  final String pokemonName;
  final String imageUrl;
  final List<String> options;
  final String correctAnswer;

  const TriviaQuestion({
    required this.pokemonId,
    required this.pokemonName,
    required this.imageUrl,
    required this.options,
    required this.correctAnswer,
  });
}
