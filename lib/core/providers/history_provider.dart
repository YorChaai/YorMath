import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/workout_result.dart';

class StreakDayInfo {
  final String dayName;
  final DateTime date;
  final bool isPracticed;
  final bool isToday;
  final bool isFuture;
  final int count;

  StreakDayInfo({
    required this.dayName,
    required this.date,
    required this.isPracticed,
    required this.isToday,
    required this.isFuture,
    required this.count,
  });
}

class HistoryProvider extends ChangeNotifier {
  static const String _storageKey = 'workout_history';
  static const String _bestStreakKey = 'best_streak';
  List<WorkoutResult> _results = [];
  bool _isLoaded = false;
  int _bestStreak = 0;

  List<WorkoutResult> get results => _results;
  bool get isLoaded => _isLoaded;

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? items = prefs.getStringList(_storageKey);
    _bestStreak = prefs.getInt(_bestStreakKey) ?? 0;
    
    if (items != null) {
      final List<WorkoutResult> loaded = [];
      for (final e in items) {
        try {
          loaded.add(WorkoutResult.fromJson(e));
        } catch (_) {}
      }
      _results = loaded;
    }
    
    final computedBest = _calculateBestStreakFromHistory();
    if (computedBest > _bestStreak) {
      _bestStreak = computedBest;
      await prefs.setInt(_bestStreakKey, _bestStreak);
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
    
    final current = currentStreak;
    if (current > _bestStreak) {
      _bestStreak = current;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_bestStreakKey, _bestStreak);
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

  int get bestStreak {
    final computed = _calculateBestStreakFromHistory();
    return computed > _bestStreak ? computed : _bestStreak;
  }

  int _calculateBestStreakFromHistory() {
    final counts = dailyGameCounts;
    if (counts.isEmpty) return 0;
    final sortedDates = counts.keys.toList()..sort();
    int maxStreak = 0;
    int currentRun = 0;
    DateTime? prev;
    for (var date in sortedDates) {
      if (prev == null || date.difference(prev).inDays == 1) {
        currentRun++;
      } else {
        currentRun = 1;
      }
      if (currentRun > maxStreak) {
        maxStreak = currentRun;
      }
      prev = date;
    }
    return maxStreak;
  }

  bool get isPracticedToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return dailyGameCounts.containsKey(today);
  }

  List<StreakDayInfo> getCurrentWeekStreak([String lang = 'Indonesian']) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Find Monday of the current week (weekday: 1 = Mon, ..., 7 = Sun)
    final monday = today.subtract(Duration(days: now.weekday - 1));
    final labels = lang == 'Indonesian'
        ? ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min']
        : ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    final List<StreakDayInfo> week = [];
    for (int i = 0; i < 7; i++) {
      final date = monday.add(Duration(days: i));
      final count = dailyGameCounts[date] ?? 0;
      week.add(StreakDayInfo(
        dayName: labels[i],
        date: date,
        isPracticed: count > 0,
        isToday: date.year == today.year && date.month == today.month && date.day == today.day,
        isFuture: date.isAfter(today),
        count: count,
      ));
    }
    return week;
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
