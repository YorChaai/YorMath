import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class WorkoutAudioService {
  static final WorkoutAudioService _instance = WorkoutAudioService._internal();
  factory WorkoutAudioService() => _instance;
  WorkoutAudioService._internal();

  final AudioPlayer _correctPlayer = AudioPlayer();
  final AudioPlayer _wrongPlayer = AudioPlayer();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    try {
      await _correctPlayer.setVolume(1.0);
      await _wrongPlayer.setVolume(1.0);
      _initialized = true;
    } catch (e) {
      debugPrint('WorkoutAudioService init error: $e');
    }
  }

  Future<void> playSuccess({bool isSoundEnabled = true}) async {
    if (!isSoundEnabled) return;
    try {
      await _correctPlayer.stop();
      await _correctPlayer.play(AssetSource('sounds/success.mp3'));
    } catch (e) {
      debugPrint('WorkoutAudioService playSuccess error: $e');
    }
  }

  Future<void> playError({bool isSoundEnabled = true}) async {
    if (!isSoundEnabled) return;
    try {
      await _wrongPlayer.stop();
      await _wrongPlayer.play(AssetSource('sounds/error.mp3'));
    } catch (e) {
      debugPrint('WorkoutAudioService playError error: $e');
    }
  }

  void dispose() {
    _correctPlayer.dispose();
    _wrongPlayer.dispose();
  }
}

