class TriviaScore {
  final int id;
  final int score;
  final int totalQuestions;
  final DateTime date;

  const TriviaScore({
    this.id = 0,
    required this.score,
    required this.totalQuestions,
    required this.date,
  });
}