// game screen — main gameplay
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../models/preset.dart';
import '../models/game_state.dart';
import '../services/tts_service.dart';
import '../services/sound_service.dart';
import '../services/history_storage.dart';
import '../models/game_history.dart';
import '../widgets/nback_grid.dart';
import '../widgets/match_button.dart';
import 'result_screen.dart';

class GameScreen extends StatefulWidget {
  final Preset preset;

  const GameScreen({super.key, required this.preset});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late GameState _gameState;
  final TtsService _tts = TtsService();
  final SoundService _sfx = SoundService();

  Timer? _autoAdvanceTimer;
  bool _showingFeedback = false;
  final FocusNode _focusNode = FocusNode();
  late DateTime _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _gameState = GameState(preset: widget.preset);

    // setup callbacks
    _gameState.onPlaySound = (letter) async {
      await _tts.speak(letter);
    };
    _gameState.onPlayFeedback = (correct) async {
      if (correct) {
        await _sfx.playCorrect();
      } else {
        await _sfx.playWrong();
      }
    };

    _initAndStart();
  }

  Future<void> _initAndStart() async {
    await _tts.init();
    await _sfx.init();

    // delay sedikit sebelum mulai
    await Future.delayed(const Duration(milliseconds: 800));
    _gameState.startGame();
    _startAutoAdvance();
    setState(() {});
  }

  void _startAutoAdvance() {
    final interval = widget.preset.intervalSeconds;
    if (interval <= 0) return; // Manual mode, no auto advance

    // auto advance sesuai interval
    final duration = Duration(milliseconds: (interval * 1000).toInt());
    _autoAdvanceTimer = Timer.periodic(duration, (_) {
      if (_gameState.status == GameStatus.playing && !_showingFeedback) {
        _showingFeedback = true;
        _gameState.nextTrial();
        setState(() {});

        // setelah feedback ditampilkan, reset
        Future.delayed(const Duration(milliseconds: 800), () {
          _showingFeedback = false;
          if (_gameState.status == GameStatus.finished) {
            _navigateToResult();
          }
          setState(() {});
        });
      }
    });
  }

  void _navigateToResult() {
    _autoAdvanceTimer?.cancel();
    // simpan riwayat permainan
    final duration = DateTime.now().difference(_startTime).inSeconds;
    final entry = GameHistoryEntry(
      id: GameHistoryEntry.generateId(),
      playedAt: _startTime,
      nLevel: widget.preset.nLevel,
      totalTrials: _gameState.responses.length,
      wins: _gameState.wins,
      positionAccuracy: _gameState.positionAccuracy,
      soundAccuracy: _gameState.soundAccuracy,
      overallAccuracy: _gameState.overallAccuracy,
      durationSeconds: duration,
      totalErrors: _gameState.totalErrors,
    );
    HistoryStorage.saveEntry(entry);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ResultScreen(gameState: _gameState)),
    );
  }

  Future<void> _confirmExit(String lang, bool isDark) async {
    _autoAdvanceTimer?.cancel();

    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFD32F2F),
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              AppLocalizations.get(lang, 'exit_game'),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          AppLocalizations.get(lang, 'exit_game_desc'),
          style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade700),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              AppLocalizations.get(lang, 'keep_playing'),
              style: const TextStyle(
                color: Color(0xFF1976D2),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              AppLocalizations.get(lang, 'exit'),
              style: const TextStyle(
                color: Color(0xFFD32F2F),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _gameState.stopGame();
      if (mounted) Navigator.pop(context);
    } else {
      // lanjut game
      _startAutoAdvance();
    }
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _focusNode.dispose();
    _gameState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = context.watch<SettingsProvider>().settings.language;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmExit(lang, isDark);
      },
      child: KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _handleKeyEvent,
        child: Scaffold(
          backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    children: [
                      // top bar: exit button + info
                      _buildTopBar(isDark, lang),

                      const SizedBox(height: 16),

                      // progress info
                      _buildProgressBar(isDark),

                      const SizedBox(height: 20),

                      // huruf saat ini
                      _buildCurrentLetter(isDark),

                      const SizedBox(height: 20),

                      // 3x3 grid
                      Expanded(
                        child: Center(
                          child: NBackGrid(
                            activePosition: _gameState.currentItem?.position,
                            isPlaying: _gameState.status == GameStatus.playing,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Manual Advance "Next" Button (above match buttons)
                      if (widget.preset.intervalSeconds <= 0 &&
                          _gameState.status == GameStatus.playing &&
                          !_showingFeedback)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: _manualNextTrial,
                              icon: const Icon(Icons.arrow_forward_rounded),
                              label: const Text(
                                'NEXT',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1976D2),
                                foregroundColor: Colors.white,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ),

                      // match buttons
                      _buildMatchButtons(lang),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isDark, String lang) {
    return Row(
      children: [
        // exit button
        IconButton(
          icon: const Icon(Icons.close_rounded, color: Color(0xFFD32F2F)),
          onPressed: () => _confirmExit(lang, isDark),
          tooltip: AppLocalizations.get(lang, 'exit'),
        ),
        const Spacer(),
        // n-back level
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF1976D2).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF1976D2).withValues(alpha: 0.3)),
          ),
          child: Text(
            '${widget.preset.nLevel}-Back',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1976D2),
            ),
          ),
        ),
        const Spacer(),
        // wins counter
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF2E7D32).withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.emoji_events_rounded,
                color: Color(0xFF2E7D32),
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                widget.preset.targetWins > 0
                    ? '${_gameState.wins}/${widget.preset.targetWins}'
                    : '${_gameState.wins}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(bool isDark) {
    final progress = _gameState.totalTrials > 0
        ? (_gameState.currentTrial + 1) / _gameState.totalTrials
        : 0.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Trial ${_gameState.currentTrial + 1} / ${_gameState.totalTrials}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
              ),
            ),
            if (widget.preset.timeLimitSeconds > 0)
              Row(
                children: [
                  const Icon(
                    Icons.timer_rounded,
                    color: Color(0xFF1976D2),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatTime(_gameState.timeRemaining),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: _gameState.timeRemaining <= 10
                          ? const Color(0xFFD32F2F)
                          : (isDark ? Colors.grey.shade300 : Colors.grey.shade800),
                    ),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: isDark ? Colors.white12 : Colors.grey.shade300,
            valueColor: const AlwaysStoppedAnimation(Color(0xFF1976D2)),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentLetter(bool isDark) {
    final letter = _gameState.currentItem?.letter ?? '?';

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Container(
        key: ValueKey('$letter-${_gameState.currentTrial}'),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          letter,
          style: const TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1976D2),
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildMatchButtons(String lang) {
    return Row(
      children: [
        // Position Match button (A)
        Expanded(
          child: MatchButton(
            label: AppLocalizations.get(lang, 'position_match_key'),
            icon: Icons.grid_view_rounded,
            isPressed: _gameState.positionPressed,
            isCorrect: _gameState.lastPositionCorrect,
            onPressed: () {
              _gameState.pressPositionMatch();
              setState(() {});
            },
          ),
        ),
        const SizedBox(width: 12),
        // Dual Match button (Space)
        Expanded(
          child: MatchButton(
            label: AppLocalizations.get(lang, 'dual_match_key'),
            icon: Icons.flash_on_rounded,
            isPressed: _gameState.positionPressed && _gameState.soundPressed,
            isCorrect:
                (_gameState.lastPositionCorrect ?? false) &&
                (_gameState.lastSoundCorrect ?? false),
            onPressed: _pressDualMatch,
          ),
        ),
        const SizedBox(width: 12),
        // Sound Match button (L)
        Expanded(
          child: MatchButton(
            label: AppLocalizations.get(lang, 'sound_match_key'),
            icon: Icons.volume_up_rounded,
            isPressed: _gameState.soundPressed,
            isCorrect: _gameState.lastSoundCorrect,
            onPressed: () {
              _gameState.pressSoundMatch();
              setState(() {});
            },
          ),
        ),
      ],
    );
  }

  void _pressDualMatch() {
    _gameState.pressPositionMatch();
    _gameState.pressSoundMatch();
    setState(() {});
  }

  void _manualNextTrial() {
    if (_showingFeedback) return;
    _showingFeedback = true;
    _gameState.nextTrial();
    setState(() {});

    Future.delayed(const Duration(milliseconds: 800), () {
      _showingFeedback = false;
      if (_gameState.status == GameStatus.finished) {
        _navigateToResult();
      }
      setState(() {});
    });
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.keyA) {
        _gameState.pressPositionMatch();
        setState(() {});
      } else if (event.logicalKey == LogicalKeyboardKey.keyL) {
        _gameState.pressSoundMatch();
        setState(() {});
      } else if (event.logicalKey == LogicalKeyboardKey.space) {
        _pressDualMatch();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight &&
          widget.preset.intervalSeconds <= 0) {
        _manualNextTrial();
      }
    }
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
