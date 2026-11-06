import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as flutter_services;
import 'package:provider/provider.dart';
import '../../../core/providers/workout_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/providers/mastery_provider.dart';
import '../../../data/models/workout_result.dart';
import '../widgets/keypad_widget.dart';
import 'result_screen.dart';
import '../../../core/providers/history_provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/models/learn_config.dart';
import '../../../data/models/math_problem.dart';

class WorkoutScreen extends StatelessWidget {
  final String operation;
  final LearnConfig? learnConfig;
  final bool? overrideNegativeNumbers;
  final List<MathProblem>? customProblems;

  const WorkoutScreen({
    super.key,
    required this.operation,
    this.learnConfig,
    this.overrideNegativeNumbers,
    this.customProblems,
  });

  @override
  Widget build(BuildContext context) {
    final baseSettings = Provider.of<SettingsProvider>(context).settings;
    final settings = overrideNegativeNumbers != null
        ? baseSettings.copyWith(isNegativeNumbersEnabled: overrideNegativeNumbers)
        : baseSettings;
    final masteryProvider = Provider.of<MasteryProvider>(context, listen: false);
    final lang = settings.language;
    const primaryColor = Color(0xFF0288D1);

    final showNegative = settings.isNegativeNumbersEnabled || operation == 'Negative Numbers';
    final showDecimal = operation == 'Desimal' || operation == 'Pecahan';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChangeNotifierProvider(
      create: (_) => WorkoutProvider(
        settings: settings,
        operation: operation,
        learnConfig: learnConfig,
        masteryProvider: masteryProvider,
        customProblems: customProblems,
      ),
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
        appBar: AppBar(
          backgroundColor: isDark ? const Color(0xFF1E1E2E) : primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: Consumer<WorkoutProvider>(
              builder: (context, provider, child) {
                double progress = 0.0;
                final isCustom = customProblems != null && customProblems!.isNotEmpty;
                if (!isCustom && settings.isDurationMode) {
                  final totalSec = settings.durationMinutes * 60;
                  if (totalSec > 0) {
                    progress = (1.0 - (provider.remainingSeconds / totalSec)).clamp(0.0, 1.0);
                  }
                } else {
                  final totalQ = isCustom ? customProblems!.length : settings.questionCount;
                  if (totalQ > 0) {
                    progress = ((provider.questionIndex - 1) / totalQ).clamp(0.0, 1.0);
                  }
                }
                return LinearProgressIndicator(
                  value: progress,
                  backgroundColor: isDark ? Colors.white12 : Colors.white24,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? const Color(0xFF00E676) : const Color(0xFF69F0AE),
                  ),
                  minHeight: 4,
                );
              },
            ),
          ),
          title: Consumer<WorkoutProvider>(
            builder: (context, provider, child) {
              if (settings.isDurationMode) {
                return Text(
                  '${AppLocalizations.get(lang, "time")} ${_formatTime(provider.remainingSeconds)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                );
              }
              if (settings.isDisplayTimeEnabled) {
                return Text(
                  '${AppLocalizations.get(lang, "time")} ${_formatTime(provider.elapsedSeconds)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                );
              }
              return Text(
                '${AppLocalizations.get(lang, "questions")}: ${provider.questionIndex}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              );
            },
          ),
          centerTitle: true,
          actions: [
            Consumer<WorkoutProvider>(
              builder: (context, provider, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.lightbulb_outline, color: Colors.white),
                      onPressed: () => _showHintDialog(context, provider),
                    ),
                    if (!settings.autoConfirm)
                      TextButton(
                        onPressed: () => provider.submitAnswer(),
                        child: Text(
                          lang == 'English' ? "Next" : "Lanjut",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 8),
                  ],
                );
              },
            ),
          ],
        ),
        body: Consumer<WorkoutProvider>(
          builder: (context, provider, child) {
            if (provider.status == WorkoutStatus.finished) {
              if (!provider.isFinishHandled) {
                provider.markFinishHandled();
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  final result = WorkoutResult(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    operation: provider.operation,
                    isDurationMode: settings.isDurationMode,
                    limitValue: settings.isDurationMode ? settings.durationMinutes : settings.questionCount,
                    difficulty: settings.difficulty,
                    score: settings.isDurationMode ? provider.correctAnswers : provider.elapsedSeconds,
                    timestamp: DateTime.now(),
                  );

                  final historyProvider = context.read<HistoryProvider>();
                  await historyProvider.addResult(result);

                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResultScreen(
                          result: result,
                          answerRecords: provider.answerRecords,
                          firstTryCorrectCount: provider.firstTryCorrectCount,
                        ),
                      ),
                    );
                  }
                });
              }
              return const Center(child: CircularProgressIndicator());
            }

            return Focus(
              autofocus: true,
              onKeyEvent: (node, event) {
                if (event is! flutter_services.KeyDownEvent) return KeyEventResult.ignored;

                final String char = event.character ?? '';
                if (RegExp(r'^[0-9.\-]$').hasMatch(char)) {
                  provider.appendAnswer(char);
                  return KeyEventResult.handled;
                } else if (event.logicalKey == flutter_services.LogicalKeyboardKey.backspace) {
                  provider.deleteAnswer();
                  return KeyEventResult.handled;
                }
                return KeyEventResult.ignored;
              },
              child: Stack(
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: Column(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                              child: Column(
                                children: [
                                  // Question Card
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 20),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                                      border: Border.all(
                                        color: isDark ? Colors.white12 : const Color(0xFFCFD8DC),
                                        width: 1.5,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.03),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            provider.currentProblem?.questionText ?? '',
                                            style: TextStyle(
                                              fontSize: 44,
                                              fontWeight: FontWeight.bold,
                                              color: isDark ? Colors.white : Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // Answer Input Box
                                  Container(
                                    width: double.infinity,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: provider.isLastAnswerCorrect == false
                                          ? (isDark ? const Color(0xFF4A1818) : const Color(0xFFFFEBEE))
                                          : (provider.isLastAnswerCorrect == true
                                              ? (isDark ? const Color(0xFF143E1F) : const Color(0xFFE8F5E9))
                                              : (isDark ? const Color(0xFF26263B) : Colors.white)),
                                      border: Border.all(
                                        color: provider.isLastAnswerCorrect == false
                                            ? Colors.redAccent
                                            : (provider.isLastAnswerCorrect == true
                                                ? Colors.green
                                                : (isDark ? Colors.white24 : const Color(0xFF90CAF9))),
                                        width: 1.5,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            provider.userAnswer.isEmpty ? ' ' : provider.userAnswer,
                                            style: TextStyle(
                                              fontSize: 40,
                                              fontWeight: FontWeight.bold,
                                              color: provider.isLastAnswerCorrect == false
                                                  ? Colors.red
                                                  : (provider.isLastAnswerCorrect == true
                                                      ? Colors.green
                                                      : (isDark ? Colors.white : Colors.black87)),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Keypad
                          KeypadWidget(
                            onKeyPress: (val) => provider.appendAnswer(val),
                            onDelete: () => provider.deleteAnswer(),
                            size: settings.keypadSize,
                            type: settings.keypadType,
                            showNegative: showNegative,
                            showDecimal: showDecimal || (provider.currentProblem?.answer.contains('.') ?? false),
                          ),
                          const SizedBox(height: 6),
                        ],
                      ),
                    ),
                  ),

                  // Countdown Overlay (Math Workout 3-2-1 Style, Tap to Skip)
                  if (provider.status == WorkoutStatus.countdown)
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: () => provider.skipCountdown(),
                        child: Container(
                          color: primaryColor,
                          child: Center(
                            child: Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3.5),
                              ),
                              child: Center(
                                child: Text(
                                  provider.countdownValue.toString(),
                                  style: const TextStyle(
                                    fontSize: 68,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showHintDialog(BuildContext context, WorkoutProvider provider) {
    if (provider.status != WorkoutStatus.playing || provider.currentProblem == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Bantuan / Hint'),
        content: const Text('Apakah kamu ingin melihat jawaban untuk soal ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showAnswerDialog(context, provider.currentProblem!.answer);
            },
            child: const Text('Lihat', style: TextStyle(color: Color(0xFF0288D1), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showAnswerDialog(BuildContext context, String answer) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Jawaban Benar'),
        content: Text(
          answer,
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup', style: TextStyle(color: Color(0xFF0288D1))),
          ),
        ],
      ),
    );
  }

  String _formatTime(int totalSeconds) {
    int m = (totalSeconds % 3600) ~/ 60;
    int s = totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
