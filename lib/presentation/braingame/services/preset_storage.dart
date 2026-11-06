// preset storage service — simpan/load preset ke shared_preferences
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/preset.dart';

class PresetStorage {
  static const String _key = 'braingame_presets';

  static Future<List<Preset>> loadPresets() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);

    if (jsonString == null) {
      // buat default preset 1
      final defaults = [Preset.defaultPreset(1)];
      await savePresets(defaults);
      return defaults;
    }

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList
        .map((json) => Preset.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  static Future<void> savePresets(List<Preset> presets) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(presets.map((p) => p.toJson()).toList());
    await prefs.setString(_key, jsonString);
  }

  static Future<void> addPreset(Preset preset) async {
    final presets = await loadPresets();
    presets.add(preset);
    await savePresets(presets);
  }

  static Future<void> updatePreset(Preset preset) async {
    final presets = await loadPresets();
    final index = presets.indexWhere((p) => p.id == preset.id);
    if (index != -1) {
      presets[index] = preset;
      await savePresets(presets);
    }
  }

  static Future<void> deletePreset(String id) async {
    final presets = await loadPresets();
    presets.removeWhere((p) => p.id == id);
    await savePresets(presets);
  }
}
