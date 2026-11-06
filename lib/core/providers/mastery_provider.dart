import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MasteryProvider extends ChangeNotifier {
  final SharedPreferences _prefs;

  MasteryProvider(this._prefs);

  /// Get the mastery score for a specific equation. 0 to 5.
  int getScore(String operation, int base, int rangeVal) {
    final key = _getKey(operation, base, rangeVal);
    return _prefs.getInt(key) ?? 0;
  }

  /// Update the mastery score. 
  /// Max score is 5, min score is 0.
  Future<void> updateScore(String operation, int base, int rangeVal, bool isCorrect) async {
    final key = _getKey(operation, base, rangeVal);
    int currentScore = getScore(operation, base, rangeVal);

    if (isCorrect) {
      if (currentScore < 5) currentScore++;
    } else {
      if (currentScore > 0) currentScore--;
    }

    await _prefs.setInt(key, currentScore);
    notifyListeners();
  }

  String _getKey(String operation, int base, int rangeVal) {
    return 'mastery_${operation}_${base}_$rangeVal';
  }
}
