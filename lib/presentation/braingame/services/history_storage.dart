// penyimpanan riwayat game ke shared_preferences
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_history.dart';

class HistoryStorage {
  static const _key = 'braingame_game_history';

  // simpan satu entry baru
  static Future<void> saveEntry(GameHistoryEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await loadAll();
    list.add(entry);
    final jsonList = list.map((e) => e.toJson()).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
  }

  // load semua riwayat
  static Future<List<GameHistoryEntry>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List;
    return decoded
        .map((e) => GameHistoryEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ambil entries untuk tanggal tertentu
  static Future<List<GameHistoryEntry>> getEntriesForDate(DateTime date) async {
    final all = await loadAll();
    return all
        .where(
          (e) =>
              e.playedAt.year == date.year &&
              e.playedAt.month == date.month &&
              e.playedAt.day == date.day,
        )
        .toList();
  }

  // hitung jumlah game per hari (untuk heatmap)
  static Future<Map<DateTime, int>> getDailyGameCounts() async {
    final all = await loadAll();
    final Map<DateTime, int> counts = {};
    for (final entry in all) {
      final day = DateTime(
        entry.playedAt.year,
        entry.playedAt.month,
        entry.playedAt.day,
      );
      counts[day] = (counts[day] ?? 0) + 1;
    }
    return counts;
  }
}
