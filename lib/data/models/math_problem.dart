class MathProblem {
  final String questionText;
  final String answer;
  final Map<String, dynamic>? metadata;

  MathProblem({
    required this.questionText,
    required this.answer,
    this.metadata,
  });
}
