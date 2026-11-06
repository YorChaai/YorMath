import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../data/models/app_settings.dart';
import '../../data/models/math_problem.dart';
import '../../data/models/learn_config.dart';
import '../utils/math_generator.dart';
import '../services/workout_audio_service.dart';
import 'mastery_provider.dart';

class AnswerRecord {
  final String questionText;
  final String userAnswer;
  final String correctAnswer;
  final bool isCorrect;

  AnswerRecord({
    required this.questionText,
    required this.userAnswer,
    required this.correctAnswer,
    required this.isCorrect,
  });
}

enum WorkoutStatus {
  countdown,
  playing,
  finished,
}

class WorkoutProvider extends ChangeNotifier {
  final AppSettings settings;
  final String operation;
  final MathGenerator _generator = MathGenerator();

  WorkoutStatus _status = WorkoutStatus.countdown;
  WorkoutStatus get status => _status;

  int _countdownValue = 3;
  int get countdownValue => _countdownValue;

  int _elapsedSeconds = 0;
  int get elapsedSeconds => _elapsedSeconds;

  int _remainingSeconds = 0;
  int get remainingSeconds => _remainingSeconds;

  int _questionIndex = 1;
  int get questionIndex => _questionIndex;

  int _correctAnswers = 0;
  int get correctAnswers => _correctAnswers;

  MathProblem? _currentProblem;
  MathProblem? get currentProblem => _currentProblem;

  String _userAnswer = '';
  String get userAnswer => _userAnswer;

  bool _isProcessingDelay = false;
  bool get isProcessingDelay => _isProcessingDelay;

  final List<AnswerRecord> _answerRecords = [];
  List<AnswerRecord> get answerRecords => _answerRecords;

  int _firstTryCorrectCount = 0;
  int get firstTryCorrectCount => _firstTryCorrectCount;

  bool _currentQuestionAttempted = false;
  String? _firstWrongAnswer;

  bool _isFinishHandled = false;
  bool get isFinishHandled => _isFinishHandled;
  void markFinishHandled() {
    _isFinishHandled = true;
  }

  bool? _isLastAnswerCorrect;
  bool? get isLastAnswerCorrect => _isLastAnswerCorrect;

  Timer? _gameTimer;
  Timer? _countdownTimer;

  final LearnConfig? learnConfig;
  final MasteryProvider? masteryProvider;
  final List<MathProblem>? customProblems;

  WorkoutProvider({
    required this.settings, 
    required this.operation, 
    this.learnConfig,
    this.masteryProvider,
    this.customProblems,
  }) {
    if (settings.isDurationMode && (customProblems == null || customProblems!.isEmpty)) {
      _remainingSeconds = settings.durationMinutes * 60;
    }
    _startCountdown();
  }

  void _startCountdown() {
    _status = WorkoutStatus.countdown;
    _countdownValue = 3;
    notifyListeners();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownValue > 1) {
        _countdownValue--;
        notifyListeners();
      } else {
        _countdownTimer?.cancel();
        _startGame();
      }
    });
  }

  void skipCountdown() {
    if (_status == WorkoutStatus.countdown) {
      _countdownTimer?.cancel();
      _startGame();
    }
  }

  void _startGame() {
    _status = WorkoutStatus.playing;
    _generateNextProblem();
    
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedSeconds++;
      if (settings.isDurationMode) {
        _remainingSeconds--;
        if (_remainingSeconds <= 0) {
          _finishGame();
        }
      }
      notifyListeners();
    });
  }

  void _generateNextProblem() {
    if (customProblems != null && customProblems!.isNotEmpty) {
      if (_questionIndex <= customProblems!.length) {
        _currentProblem = customProblems![_questionIndex - 1];
      } else {
        _finishGame();
        return;
      }
    } else {
      _currentProblem = _generator.generate(operation, settings, learnConfig: learnConfig);
    }
    _userAnswer = '';
    _isLastAnswerCorrect = null;
    notifyListeners();
  }

  void appendAnswer(String char) {
    if (_status != WorkoutStatus.playing || _isProcessingDelay) return;
    _userAnswer += char;
    notifyListeners();
    if (settings.autoConfirm) {
      _checkAnswer(force: false);
    }
  }

  void submitAnswer() {
    if (_status != WorkoutStatus.playing || _isProcessingDelay) return;
    _checkAnswer(force: true);
  }

  void deleteAnswer() {
    if (_status != WorkoutStatus.playing || _userAnswer.isEmpty || _isProcessingDelay) return;
    _userAnswer = _userAnswer.substring(0, _userAnswer.length - 1);
    notifyListeners();
  }

  Future<void> _checkAnswer({bool force = false}) async {
    if (_currentProblem == null) return;

    final String correctAnswer = _currentProblem!.answer;

    if (_userAnswer == correctAnswer) {
      _answerRecords.add(AnswerRecord(
        questionText: _currentProblem!.questionText,
        userAnswer: _currentQuestionAttempted ? (_firstWrongAnswer ?? _userAnswer) : correctAnswer,
        correctAnswer: correctAnswer,
        isCorrect: !_currentQuestionAttempted,
      ));
      _firstWrongAnswer = null;
      // CORRECT
      WorkoutAudioService().playSuccess(isSoundEnabled: settings.isSoundEnabled);

      if (learnConfig != null && masteryProvider != null && _currentProblem!.metadata != null) {
        final meta = _currentProblem!.metadata!;
        masteryProvider!.updateScore(meta['operation'], meta['base'], meta['rangeVal'], true);
      }
      _isProcessingDelay = true;
      _isLastAnswerCorrect = true;
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 500));

      _correctAnswers++;

      if (!_currentQuestionAttempted) {
        _firstTryCorrectCount++;
      }
      _currentQuestionAttempted = false;
      
      final isCustomList = customProblems != null && customProblems!.isNotEmpty;
      final totalTarget = isCustomList ? customProblems!.length : settings.questionCount;
      
      if (isCustomList || !settings.isDurationMode) {
        if (_questionIndex >= totalTarget) {
          _finishGame();
        } else {
          _questionIndex++;
          _generateNextProblem();
        }
      } else {
        _questionIndex++;
        _generateNextProblem();
      }
      
      _isProcessingDelay = false;
      notifyListeners();

    } else if (force || (_userAnswer != '-' && _userAnswer.length >= correctAnswer.length)) {
      _firstWrongAnswer ??= _userAnswer;
      // INCORRECT (Panjang digit sudah sama atau lebih, tapi salah, atau di-submit paksa)
      WorkoutAudioService().playError(isSoundEnabled: settings.isSoundEnabled);
      HapticFeedback.mediumImpact();

      if (learnConfig != null && masteryProvider != null && _currentProblem!.metadata != null) {
        final meta = _currentProblem!.metadata!;
        masteryProvider!.updateScore(meta['operation'], meta['base'], meta['rangeVal'], false);
      }
      _isProcessingDelay = true;
      _isLastAnswerCorrect = false;
      notifyListeners();
      _currentQuestionAttempted = true;

      await Future.delayed(const Duration(milliseconds: 500));

      _userAnswer = '';
      _isLastAnswerCorrect = null;
      _isProcessingDelay = false;
      notifyListeners();

    } else {
      // POSSIBLE (Tunggu input berikutnya)
      // Tidak melakukan apa-apa
    }
  }

  void _finishGame() {
    _gameTimer?.cancel();
    _status = WorkoutStatus.finished;
    notifyListeners();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _gameTimer?.cancel();
    super.dispose();
  }
}
