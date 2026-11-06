import 'dart:convert';

class WorkoutResult {
  final String id;
  final String operation;
  final bool isDurationMode;
  final int limitValue; // If duration mode: durationMinutes. If question mode: questionCount.
  final String difficulty;
  final int score; // If duration mode: correct answers. If question mode: elapsed seconds.
  final DateTime timestamp;

  WorkoutResult({
    required this.id,
    required this.operation,
    required this.isDurationMode,
    required this.limitValue,
    required this.difficulty,
    required this.score,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'operation': operation,
      'isDurationMode': isDurationMode,
      'limitValue': limitValue,
      'difficulty': difficulty,
      'score': score,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory WorkoutResult.fromMap(Map<String, dynamic> map) {
    return WorkoutResult(
      id: map['id'] ?? '',
      operation: map['operation'] ?? '',
      isDurationMode: map['isDurationMode'] ?? false,
      limitValue: map['limitValue']?.toInt() ?? 0,
      difficulty: map['difficulty'] ?? '',
      score: map['score']?.toInt() ?? 0,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
    );
  }

  String toJson() => json.encode(toMap());

  factory WorkoutResult.fromJson(String source) => WorkoutResult.fromMap(json.decode(source));
}
