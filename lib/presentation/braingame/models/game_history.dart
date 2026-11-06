// model riwayat permainan

class GameHistoryEntry {
  final String id;
  final DateTime playedAt;
  final int nLevel;
  final int totalTrials;
  final int wins;
  final double positionAccuracy;
  final double soundAccuracy;
  final double overallAccuracy;
  final int durationSeconds;
  final int totalErrors;

  GameHistoryEntry({
    required this.id,
    required this.playedAt,
    required this.nLevel,
    required this.totalTrials,
    required this.wins,
    required this.positionAccuracy,
    required this.soundAccuracy,
    required this.overallAccuracy,
    required this.durationSeconds,
    this.totalErrors = 0, // default 0 for backward compatibility
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'playedAt': playedAt.toIso8601String(),
    'nLevel': nLevel,
    'totalTrials': totalTrials,
    'wins': wins,
    'positionAccuracy': positionAccuracy,
    'soundAccuracy': soundAccuracy,
    'overallAccuracy': overallAccuracy,
    'durationSeconds': durationSeconds,
    'totalErrors': totalErrors,
  };

  factory GameHistoryEntry.fromJson(Map<String, dynamic> json) {
    return GameHistoryEntry(
      id: json['id'] as String,
      playedAt: DateTime.parse(json['playedAt'] as String),
      nLevel: json['nLevel'] as int,
      totalTrials: json['totalTrials'] as int,
      wins: json['wins'] as int,
      positionAccuracy: (json['positionAccuracy'] as num).toDouble(),
      soundAccuracy: (json['soundAccuracy'] as num).toDouble(),
      overallAccuracy: (json['overallAccuracy'] as num).toDouble(),
      durationSeconds: json['durationSeconds'] as int,
      totalErrors: (json['totalErrors'] as int?) ?? 0,
    );
  }

  // helper: buat dari GameState setelah game selesai
  static String generateId() =>
      DateTime.now().millisecondsSinceEpoch.toString();
}
