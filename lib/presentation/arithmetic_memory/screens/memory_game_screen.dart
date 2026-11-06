import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/memory_generator.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../data/models/app_settings.dart';
import 'memory_result_screen.dart';
import '../../../core/localization/app_localizations.dart';
import '../../workout/widgets/keypad_widget.dart';
import '../../../core/utils/generators/safe_random.dart';
import '../../../core/providers/history_provider.dart';
import '../../../data/models/workout_result.dart';

class MemoryGameScreen extends StatefulWidget {
  final String difficulty;
  final int steps;

  const MemoryGameScreen({
    super.key,
    required this.difficulty,
    required this.steps,
  });

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> with SingleTickerProviderStateMixin {
  late ArithmeticMemoryGenerator _generator;
  late int _startNumber;
  late List<MemoryStep> _sequence;
  
  int _currentStepIndex = -1; // -1 means showing start number
  Timer? _stepTimer;
  
  // Progress bar animation
  late AnimationController _progressController;
  
  // Finished sequence flag
  bool _isFinished = false;
  
  // User input
  String _userInput = '';

  @override
  void initState() {
    super.initState();
    _generator = ArithmeticMemoryGenerator();
    
    // We defer the generation until build so we can access context,
    // or we can read it directly here using read()
    final baseSettings = context.read<SettingsProvider>().settings;
    final effectiveSettings = baseSettings.copyWith(difficulty: widget.difficulty);
    
    // Determine start number bounds same as var 1
    int max1 = 9;
    if (widget.difficulty == 'Custom') {
      max1 = effectiveSettings.memoryPresets.firstWhere(
        (p) => p.id == effectiveSettings.activeMemoryPresetId, 
        orElse: () => CustomPreset(id: '', name: '', xDigit: 1)
      ).baseDigit ?? 100;
    } else {
      if (widget.difficulty == 'Medium') max1 = 99;
      if (widget.difficulty == 'Hard') max1 = 999;
      if (widget.difficulty == 'Extreme') max1 = 999;
    }
    
    _startNumber = safeRandomInt(Random(), max1) + 1;
    if (effectiveSettings.isNegativeNumbersEnabled && Random().nextBool()) {
      _startNumber = -_startNumber;
    }
    
    _sequence = _generator.generateSequence(_startNumber, widget.steps, effectiveSettings);
    
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    
    _startGame();
  }
  
  void _startGame() {
    _startNextStep();
  }
  
  void _startNextStep() {
    if (_currentStepIndex >= widget.steps - 1) {
      // Game finished, show input pad
      setState(() {
        _isFinished = true;
      });
      return;
    }
    
    setState(() {
      _currentStepIndex++;
    });
    
    _progressController.reset();
    _progressController.forward();
    
    _stepTimer = Timer(const Duration(seconds: 5), () {
      _startNextStep();
    });
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    _progressController.dispose();
    super.dispose();
  }


  void _submitAnswer() {
    if (_userInput.isEmpty || _userInput == '-') return;
    
    int finalAnswer = int.parse(_userInput);
    int correctAnswer = _sequence.last.runningTotal;
    bool isCorrect = finalAnswer == correctAnswer;

    final result = WorkoutResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      operation: 'Arithmetic Memory',
      isDurationMode: false,
      limitValue: widget.steps,
      difficulty: widget.difficulty,
      score: isCorrect ? 1 : 0,
      timestamp: DateTime.now(),
    );
    context.read<HistoryProvider>().addResult(result);
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MemoryResultScreen(
          isCorrect: isCorrect,
          userAnswer: finalAnswer,
          startNumber: _startNumber,
          sequence: _sequence,
          difficulty: widget.difficulty,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<SettingsProvider>().settings.language;
    String diff = AppLocalizations.get(lang, widget.difficulty.toLowerCase());
    String stepText = lang == 'Indonesian' ? 'Langkah' : 'Step';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text('$diff - $stepText ${_currentStepIndex + 1}/${widget.steps}')
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0D6EFD),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar
            if (!_isFinished)
              AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  return LinearProgressIndicator(
                    value: 1.0 - _progressController.value,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _progressController.value > 0.8 ? Colors.red : Colors.green,
                    ),
                  );
                },
              ),
              
            Expanded(
              child: Center(
                child: _isFinished
                    ? _buildInputArea(lang)
                    : _buildDisplayArea(),
              ),
            ),
            
            if (_isFinished)
              _buildKeypad(lang, context),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDisplayArea() {
    String displayText = '';
    if (_currentStepIndex == -1) {
      displayText = '$_startNumber'; // Should not happen with current logic as it increments immediately
    } else if (_currentStepIndex == 0) {
      displayText = '$_startNumber\n↓\n${_sequence[0].displayOperation}';
    } else {
      displayText = _sequence[_currentStepIndex].displayOperation;
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          displayText,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
        ),
      ),
    );
  }
  
  Widget _buildInputArea(String lang) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(lang == 'Indonesian' ? 'Hasil Akhir?' : 'Final Result?', style: const TextStyle(fontSize: 24, color: Colors.grey)),
        const SizedBox(height: 16),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            _userInput.isEmpty ? '?' : _userInput,
            style: TextStyle(
              fontSize: 64, 
              fontWeight: FontWeight.bold, 
              color: _userInput.isEmpty ? Colors.grey : Colors.black
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKeypad(String lang, BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    return KeypadWidget(
      size: settingsProvider.settings.keypadSize,
      type: settingsProvider.settings.keypadType,
      onKeyPress: (label) {
        if (label == '-') {
          if (_userInput.isEmpty) {
            setState(() {
              _userInput = '-';
            });
          }
        } else if (label == '.') {
          if (!_userInput.contains('.')) {
            setState(() {
              _userInput += '.';
            });
          }
        } else {
          setState(() {
            _userInput += label;
          });
        }
        if (settingsProvider.settings.autoConfirm) {
          // For memory game, autoConfirm is tricky because we don't know the expected length
          // but we can check if it perfectly matches.
          if (_userInput == _sequence.last.runningTotal.toString()) {
            _submitAnswer();
          } else if (_userInput.length >= _sequence.last.runningTotal.toString().length && _userInput != '-') {
            _submitAnswer();
          }
        }
      },
      onDelete: () {
        if (_userInput.isNotEmpty) {
          setState(() {
            _userInput = _userInput.substring(0, _userInput.length - 1);
          });
        }
      },
    );
  }
}
