// game state management
import 'dart:async';
import 'package:flutter/material.dart';
import 'sequence_generator.dart';
import 'preset.dart';

enum GameStatus { ready, playing, paused, finished }

// response player per trial
class TrialResponse {
  final bool positionMatch; // player bilang posisi match
  final bool soundMatch; // player bilang huruf match
  final bool actualPosMatch; // apakah posisi benar-benar match
  final bool actualSndMatch; // apakah huruf benar-benar match

  const TrialResponse({
    required this.positionMatch,
    required this.soundMatch,
    required this.actualPosMatch,
    required this.actualSndMatch,
  });

  bool get positionCorrect => positionMatch == actualPosMatch;
  bool get soundCorrect => soundMatch == actualSndMatch;
  bool get bothCorrect => positionCorrect && soundCorrect;
}

class GameState extends ChangeNotifier {
  final Preset preset;
  late List<SequenceItem> _sequence;
  final List<TrialResponse> _responses = [];

  GameStatus _status = GameStatus.ready;
  int _currentTrial = 0;
  int _wins = 0;
  int _timeRemaining = 0;
  Timer? _gameTimer;
  Timer? _trialTimer;

  // feedback state (untuk animasi warna hijau/merah)
  bool? _lastPositionCorrect;
  bool? _lastSoundCorrect;
  bool _positionPressed = false;
  bool _soundPressed = false;

  GameState({required this.preset}) {
    final generator = SequenceGenerator();
    _sequence = generator.generate(preset.sessionLength, preset.nLevel);
    _timeRemaining = preset.timeLimitSeconds;
  }

  // getters
  GameStatus get status => _status;
  int get currentTrial => _currentTrial;
  int get totalTrials => _sequence.length;
  int get wins => _wins;
  int get timeRemaining => _timeRemaining;
  List<TrialResponse> get responses => List.unmodifiable(_responses);
  bool? get lastPositionCorrect => _lastPositionCorrect;
  bool? get lastSoundCorrect => _lastSoundCorrect;
  bool get positionPressed => _positionPressed;
  bool get soundPressed => _soundPressed;

  SequenceItem? get currentItem =>
      _currentTrial < _sequence.length ? _sequence[_currentTrial] : null;

  // apakah current trial seharusnya match posisi
  bool get isPositionMatch {
    if (_currentTrial < preset.nLevel) return false;
    return _sequence[_currentTrial].position ==
        _sequence[_currentTrial - preset.nLevel].position;
  }

  // apakah current trial seharusnya match huruf
  bool get isSoundMatch {
    if (_currentTrial < preset.nLevel) return false;
    return _sequence[_currentTrial].letter ==
        _sequence[_currentTrial - preset.nLevel].letter;
  }

  // score calculations
  int get totalPositionCorrect =>
      _responses.where((r) => r.positionCorrect).length;
  int get totalSoundCorrect => _responses.where((r) => r.soundCorrect).length;
  int get totalBothCorrect => _responses.where((r) => r.bothCorrect).length;

  double get positionAccuracy =>
      _responses.isEmpty ? 0 : totalPositionCorrect / _responses.length;
  double get soundAccuracy =>
      _responses.isEmpty ? 0 : totalSoundCorrect / _responses.length;
  double get overallAccuracy =>
      _responses.isEmpty ? 0 : totalBothCorrect / _responses.length;

  // position match details
  int get positionHits =>
      _responses.where((r) => r.positionMatch && r.actualPosMatch).length;
  int get positionMisses =>
      _responses.where((r) => !r.positionMatch && r.actualPosMatch).length;
  int get positionFalseAlarms =>
      _responses.where((r) => r.positionMatch && !r.actualPosMatch).length;

  // sound match details
  int get soundHits =>
      _responses.where((r) => r.soundMatch && r.actualSndMatch).length;
  int get soundMisses =>
      _responses.where((r) => !r.soundMatch && r.actualSndMatch).length;
  int get soundFalseAlarms =>
      _responses.where((r) => r.soundMatch && !r.actualSndMatch).length;

  // total kesalahan (salah tekan atau lupa tekan)
  int get totalErrors =>
      positionMisses + positionFalseAlarms + soundMisses + soundFalseAlarms;

  // callback saat perlu play sound
  Function(String letter)? onPlaySound;
  Function(bool correct)? onPlayFeedback;

  void startGame() {
    _status = GameStatus.playing;
    _currentTrial = 0;
    _wins = 0;
    _responses.clear();
    _positionPressed = false;
    _soundPressed = false;
    _lastPositionCorrect = null;
    _lastSoundCorrect = null;

    // start countdown timer jika ada time limit
    if (preset.timeLimitSeconds > 0) {
      _timeRemaining = preset.timeLimitSeconds;
      _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _timeRemaining--;
        if (_timeRemaining <= 0) {
          _finishGame();
        }
        notifyListeners();
      });
    }

    notifyListeners();

    // play first stimulus
    _playCurrentStimulus();
  }

  void _playCurrentStimulus() {
    if (_currentTrial < _sequence.length && _status == GameStatus.playing) {
      onPlaySound?.call(_sequence[_currentTrial].letter);
    }
  }

  // player menekan tombol position match
  void pressPositionMatch() {
    if (_status != GameStatus.playing || _positionPressed) return;
    _positionPressed = true;
    notifyListeners();
  }

  // player menekan tombol sound match
  void pressSoundMatch() {
    if (_status != GameStatus.playing || _soundPressed) return;
    _soundPressed = true;
    notifyListeners();
  }

  // lanjut ke trial berikutnya (dipanggil dari screen setelah delay)
  void nextTrial() {
    if (_status != GameStatus.playing) return;

    // evaluate current trial
    final actualPosMatch = isPositionMatch;
    final actualSndMatch = isSoundMatch;

    final response = TrialResponse(
      positionMatch: _positionPressed,
      soundMatch: _soundPressed,
      actualPosMatch: actualPosMatch,
      actualSndMatch: actualSndMatch,
    );
    _responses.add(response);

    // tentukan feedback
    _lastPositionCorrect = response.positionCorrect;
    _lastSoundCorrect = response.soundCorrect;

    // hitung apakah ini "win" (kedua jawaban benar)
    // User request: hanya hitung jika ada yang ditekan (active correct)
    // ATAU jika ada match tapi user benar (menghindari poin dari "diam aja" pas gak ada match)
    final isPassiveCorrect =
        response.bothCorrect && !actualPosMatch && !actualSndMatch;

    // Kita hanya anggap "Win" point jika trial ini TIDAK pasif (artinya ada match yang harus dijawab)
    // dan user menjawab dengan benar.
    if (response.bothCorrect && !isPassiveCorrect) {
      _wins++;
    }

    // play feedback sound
    onPlayFeedback?.call(response.bothCorrect);

    notifyListeners();

    // check apakah game selesai
    if (_shouldFinish()) {
      // delay sedikit agar feedback terlihat
      Future.delayed(const Duration(milliseconds: 800), () {
        _finishGame();
      });
      return;
    }

    // lanjut ke trial berikutnya setelah delay
    Future.delayed(const Duration(milliseconds: 800), () {
      _currentTrial++;
      _positionPressed = false;
      _soundPressed = false;
      _lastPositionCorrect = null;
      _lastSoundCorrect = null;
      notifyListeners();

      // play next stimulus
      _playCurrentStimulus();
    });
  }

  bool _shouldFinish() {
    // selesai jika semua trial habis
    if (_currentTrial >= _sequence.length - 1) return true;

    // selesai jika target wins tercapai
    if (preset.targetWins > 0 && _wins >= preset.targetWins) return true;

    // selesai jika waktu habis (dihandle oleh timer)
    return false;
  }

  void _finishGame() {
    _status = GameStatus.finished;
    _gameTimer?.cancel();
    _trialTimer?.cancel();
    notifyListeners();
  }

  void stopGame() {
    _finishGame();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _trialTimer?.cancel();
    super.dispose();
  }
}
