// settings service — kontrol refresh rate / fps
import 'package:flutter/foundation.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _prefKeyFps = 'selected_fps';

  // singleton
  static final SettingsService _instance = SettingsService._();
  factory SettingsService() => _instance;
  SettingsService._();

  List<DisplayMode> _supportedModes = [];
  DisplayMode? _activeMode;
  int _selectedFps = 60; // default 60hz

  // getters
  List<int> get availableFpsOptions => const [30, 60, 90, 120];
  int get selectedFps => _selectedFps;
  DisplayMode? get activeMode => _activeMode;

  /// inisialisasi — panggil di main.dart
  Future<void> init() async {
    try {
      _supportedModes = await FlutterDisplayMode.supported;
      _activeMode = await FlutterDisplayMode.active;

      // load preference
      final prefs = await SharedPreferences.getInstance();
      _selectedFps = prefs.getInt(_prefKeyFps) ?? 60;

      // apply saved setting
      await _applyFps(_selectedFps);
    } catch (e) {
      // fallback jika platform tidak support (web, ios, dll)
      debugPrint('DisplayMode not supported: $e');
    }
  }

  /// set fps dan simpan preference
  Future<void> setFps(int fps) async {
    _selectedFps = fps;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefKeyFps, fps);
    await _applyFps(fps);
  }

  /// apply display mode sesuai fps (cari yang paling mendekati)
  Future<void> _applyFps(int fps) async {
    try {
      if (_supportedModes.isEmpty) return;

      // cari mode yang paling mendekati fps yang dipilih
      // prioritas: resolusi tertinggi untuk refresh rate yang sama/dekat
      DisplayMode? bestMatch;
      int bestDiff = 999;

      for (final mode in _supportedModes) {
        final hz = mode.refreshRate.round();
        final diff = (hz - fps).abs();
        if (diff < bestDiff ||
            (diff == bestDiff &&
                bestMatch != null &&
                mode.height > bestMatch.height)) {
          bestMatch = mode;
          bestDiff = diff;
        }
      }

      if (bestMatch != null) {
        await FlutterDisplayMode.setPreferredMode(bestMatch);
      } else {
        await FlutterDisplayMode.setHighRefreshRate();
      }

      // selalu refresh active mode setelah apply
      _activeMode = await FlutterDisplayMode.active;
    } catch (e) {
      debugPrint('Failed to apply display mode: $e');
    }
  }

  /// label untuk fps option
  String fpsLabel(int fps) {
    return '$fps Hz';
  }
}
