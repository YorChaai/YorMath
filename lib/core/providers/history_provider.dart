import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/workout_result.dart';

class HistoryProvider extends ChangeNotifier {
  static const String _storageKey = 'workout_history';
  List<WorkoutResult> _results = [];
  bool _isLoaded = false;

  List<WorkoutResult> get results => _results;
  bool get isLoaded => _isLoaded;

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? items = prefs.getStringList(_storageKey);
    
    if (items != null) {
      final List<WorkoutResult> loaded = [];
      for (final e in items) {
        try {
          loaded.add(WorkoutResult.fromJson(e));
        } catch (_) {}
      }
      _results = loaded;
    }
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> addResult(WorkoutResult result) async {
    _results.add(result);
    // Keep only last 1000 records to avoid huge storage
    if (_results.length > 1000) {
      _results.removeAt(0);
    }
    notifyListeners();
    await _saveHistory();
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> items = _results.map((e) => e.toJson()).toList();
    await prefs.setStringList(_storageKey, items);
  }

  // Filter history by current session config
  List<WorkoutResult> getHistoryForConfig(String operation, bool isDurationMode, int limitValue, String difficulty) {
    return _results.where((r) => 
      r.operation == operation &&
      r.isDurationMode == isDurationMode &&
      r.limitValue == limitValue &&
      r.difficulty == difficulty
    ).toList()
    ..sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Sort descending (newest first)
  }

  // Get Top 5 scores
  List<WorkoutResult> getTop5ForConfig(String operation, bool isDurationMode, int limitValue, String difficulty) {
    var filtered = getHistoryForConfig(operation, isDurationMode, limitValue, difficulty);
    // If Questions Mode: Lowest time is best. 
    // If Duration Mode or Arithmetic Memory: Highest score is best.
    filtered.sort((a, b) {
      if (isDurationMode || operation == 'Arithmetic Memory' || operation == 'Operasi Berantai') {
        return b.score.compareTo(a.score); // descending
      } else {
        return a.score.compareTo(b.score); // ascending
      }
    });
    return filtered.take(5).toList();
  }

  // --- Global Stats for Progress Screen ---

  Map<DateTime, int> get dailyGameCounts {
    final Map<DateTime, int> counts = {};
    for (var r in _results) {
      final date = DateTime(r.timestamp.year, r.timestamp.month, r.timestamp.day);
      counts[date] = (counts[date] ?? 0) + 1;
    }
    return counts;
  }

  int get totalGames => _results.length;
  
  int get activeDays => dailyGameCounts.length;

  int get currentStreak {
    final counts = dailyGameCounts;
    int streak = 0;
    DateTime checkDay = DateTime.now();
    checkDay = DateTime(checkDay.year, checkDay.month, checkDay.day);
    
    // If today is empty, check yesterday. If yesterday is empty too, streak is 0.
    if (!counts.containsKey(checkDay)) {
      checkDay = checkDay.subtract(const Duration(days: 1));
      if (!counts.containsKey(checkDay)) {
        return 0;
      }
    }

    while (counts.containsKey(checkDay)) {
      streak++;
      checkDay = checkDay.subtract(const Duration(days: 1));
    }
    return streak;
  }

  int get averageCorrect {
    if (_results.isEmpty) return 0;
    int totalCorrect = 0;
    for (var r in _results) {
      if (r.isDurationMode) {
        totalCorrect += r.score;
      } else {
        totalCorrect += r.limitValue;
      }
    }
    return (totalCorrect / _results.length).round();
  }
}
