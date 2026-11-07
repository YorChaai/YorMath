// result screen — skor akhir setelah game selesai
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../models/game_state.dart';
import 'game_screen.dart';
import 'home_screen.dart';

class ResultScreen extends StatefulWidget {
  final GameState gameState;

  const ResultScreen({super.key, required this.gameState});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _backToHome(BuildContext context) {
    bool found = false;
    Navigator.popUntil(context, (route) {
      if (route.settings.name == '/braingame_home') {
        found = true;
        return true;
      }
      return route.isFirst;
    });
    if (!found) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: const RouteSettings(name: '/braingame_home'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final gs = widget.gameState;
    final overallPct = (gs.overallAccuracy * 100).round();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = context.watch<SettingsProvider>().settings.language;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _backToHome(context);
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),

                      // trophy icon
                      _buildTrophy(overallPct),

                      const SizedBox(height: 16),

                      // overall score
                      Text(
                        '$overallPct%',
                        style: TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.w800,
                          color: _scoreColor(overallPct),
                        ),
                      ),
                      Text(
                        _scoreLabel(overallPct, lang),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // stats cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              title: AppLocalizations.get(lang, 'position'),
                              accuracy: (gs.positionAccuracy * 100).round(),
                              hits: gs.positionHits,
                              misses: gs.positionMisses,
                              falseAlarms: gs.positionFalseAlarms,
                              icon: Icons.grid_view_rounded,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              title: AppLocalizations.get(lang, 'sound'),
                              accuracy: (gs.soundAccuracy * 100).round(),
                              hits: gs.soundHits,
                              misses: gs.soundMisses,
                              falseAlarms: gs.soundFalseAlarms,
                              icon: Icons.volume_up_rounded,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // summary
                      _buildSummary(gs, isDark, lang),

                      const SizedBox(height: 28),

                      // buttons
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => GameScreen(preset: gs.preset),
                              ),
                            );
                          },
                          icon: const Icon(Icons.replay_rounded, size: 22),
                          label: Text(
                            AppLocalizations.get(lang, 'main_lagi'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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

                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: () => _backToHome(context),
                          icon: const Icon(Icons.home_rounded, size: 20),
                          label: Text(
                            AppLocalizations.get(lang, 'ke_beranda'),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isDark ? Colors.white : const Color(0xFF1976D2),
                            side: BorderSide(
                              color: isDark ? Colors.white24 : const Color(0xFF1976D2),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),

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

  Widget _buildTrophy(int pct) {
    final color = _scoreColor(pct);
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.15),
      ),
      child: Icon(
        pct >= 80
            ? Icons.emoji_events_rounded
            : pct >= 50
                ? Icons.thumb_up_rounded
                : Icons.refresh_rounded,
        size: 44,
        color: color,
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required int accuracy,
    required int hits,
    required int misses,
    required int falseAlarms,
    required IconData icon,
    required bool isDark,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF1976D2), size: 24),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$accuracy%',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: _scoreColor(accuracy),
              ),
            ),
            const SizedBox(height: 10),
            _statRow('Hits', hits, const Color(0xFF2E7D32), isDark),
            _statRow('Misses', misses, const Color(0xFFD32F2F), isDark),
            _statRow('False Alarms', falseAlarms, Colors.amber.shade800, isDark),
          ],
        ),
      ),
    );
  }

  Widget _statRow(String label, int value, Color color, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '$value',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(GameState gs, bool isDark, String lang) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _summaryRow(AppLocalizations.get(lang, 'total_trials'), '${gs.responses.length}', isDark: isDark),
            _summaryRow(AppLocalizations.get(lang, 'total_wins'), '${gs.wins}', isDark: isDark),
            _summaryRow(
              AppLocalizations.get(lang, 'total_errors'),
              '${gs.totalErrors}',
              valueColor: const Color(0xFFD32F2F),
              isDark: isDark,
            ),
            _summaryRow(
              AppLocalizations.get(lang, 'position_accuracy'),
              '${(gs.positionAccuracy * 100).round()}%',
              isDark: isDark,
            ),
            _summaryRow(
              AppLocalizations.get(lang, 'sound_accuracy'),
              '${(gs.soundAccuracy * 100).round()}%',
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {Color? valueColor, required bool isDark}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: valueColor ?? (isDark ? Colors.white : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Color _scoreColor(int pct) {
    if (pct >= 80) return const Color(0xFF2E7D32);
    if (pct >= 50) return Colors.amber.shade800;
    return const Color(0xFFD32F2F);
  }

  String _scoreLabel(int pct, String lang) {
    if (pct >= 90) return AppLocalizations.get(lang, 'score_outstanding');
    if (pct >= 80) return AppLocalizations.get(lang, 'score_great');
    if (pct >= 60) return AppLocalizations.get(lang, 'score_good');
    if (pct >= 40) return AppLocalizations.get(lang, 'score_keep_practicing');
    return AppLocalizations.get(lang, 'score_dont_give_up');
  }
}
