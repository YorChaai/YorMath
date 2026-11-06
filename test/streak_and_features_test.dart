import 'package:flutter_test/flutter_test.dart';
import 'package:mathall/core/providers/history_provider.dart';
import 'package:mathall/data/models/workout_result.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Daily Streak and History Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('HistoryProvider computes streak correctly for consecutive days', () async {
      final historyProvider = HistoryProvider();
      await historyProvider.loadHistory();

      expect(historyProvider.currentStreak, 0);
      expect(historyProvider.isPracticedToday, false);

      final now = DateTime.now();
      final todayResult = WorkoutResult(
        id: '1',
        operation: 'Penjumlahan',
        isDurationMode: false,
        limitValue: 10,
        difficulty: 'Easy',
        score: 25,
        timestamp: now,
      );

      final yesterdayResult = WorkoutResult(
        id: '2',
        operation: 'Penjumlahan',
        isDurationMode: false,
        limitValue: 10,
        difficulty: 'Easy',
        score: 28,
        timestamp: now.subtract(const Duration(days: 1)),
      );

      await historyProvider.addResult(yesterdayResult);
      await historyProvider.addResult(todayResult);

      expect(historyProvider.isPracticedToday, true);
      expect(historyProvider.currentStreak, 2);
      expect(historyProvider.bestStreak, 2);

      final week = historyProvider.getCurrentWeekStreak('Indonesian');
      expect(week.length, 7);
      expect(week.any((d) => d.isToday), true);
      expect(week.firstWhere((d) => d.isToday).isPracticed, true);
    });
  });
}

