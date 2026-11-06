// home screen - dashboard dengan 2 tombol: Play dan Presets
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../models/preset.dart';
import '../services/preset_storage.dart';
import 'preset_screen.dart';
import 'game_screen.dart';
import 'progress_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Preset? _activePreset;
  List<Preset> _presets = [];

  @override
  void initState() {
    super.initState();
    _loadPresets();
  }

  Future<void> _loadPresets() async {
    final presets = await PresetStorage.loadPresets();
    setState(() {
      _presets = presets;
      _activePreset = presets.isNotEmpty ? presets.first : null;
    });
  }

  void _startGame() {
    if (_activePreset == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(preset: _activePreset!),
      ),
    );
  }

  void _openPresets() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PresetScreen(),
      ),
    );
    // reload presets setelah kembali
    _loadPresets();
  }

  void _openProgress() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProgressScreen(),
      ),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SettingsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nLevel = _activePreset?.nLevel ?? 2;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = context.watch<SettingsProvider>().settings.language;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const Spacer(flex: 2),

                      // logo area
                      _buildLogo(nLevel, isDark, lang),

                      const Spacer(flex: 1),

                      // active preset info
                      if (_activePreset != null) _buildPresetInfo(isDark, lang),

                      const SizedBox(height: 20),

                      // preset selector dropdown
                      _buildPresetSelector(isDark),

                          const Spacer(flex: 1),

                          // tombol Play
                          _buildPlayButton(lang),

                          const SizedBox(height: 12),

                          // tombol Presets
                          _buildPresetsButton(isDark, lang),

                          const SizedBox(height: 10),

                          // tombol Progress
                          _buildProgressButton(isDark, lang),

                          const SizedBox(height: 10),

                          // tombol Settings
                          _buildSettingsButton(isDark, lang),

                          const Spacer(flex: 2),
                        ],
                      ),
                    ),
                  ),
                ),
            // Back button (top-left)
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded, size: 24),
                color: const Color(0xFF1976D2),
                splashRadius: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(int nLevel, bool isDark, String lang) {
    return Column(
      children: [
        // brain icon
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF1976D2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1976D2).withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.psychology_rounded,
            size: 48,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 18),
        // title
        Text(
          'Dual $nLevel-Back',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF1A237E),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          AppLocalizations.get(lang, 'brain_training_game'),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildPresetInfo(bool isDark, String lang) {
    final p = _activePreset!;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _infoItem(Icons.repeat, '${p.nLevel}-Back', AppLocalizations.get(lang, 'level'), isDark),
            _infoItem(
              Icons.emoji_events_rounded,
              p.targetWins > 0 ? '${p.targetWins}' : '∞',
              AppLocalizations.get(lang, 'target'),
              isDark,
            ),
            _infoItem(
              Icons.timer_rounded,
              p.timeLimitSeconds > 0 ? _formatTime(p.timeLimitSeconds) : '∞',
              AppLocalizations.get(lang, 'time_label'),
              isDark,
            ),
            _infoItem(Icons.grid_view_rounded, '${p.sessionLength}', AppLocalizations.get(lang, 'trial_label'), isDark),
          ],
        ),
      ),
    );
  }

  Widget _infoItem(IconData icon, String value, String label, bool isDark) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF1976D2), size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildPresetSelector(bool isDark) {
    if (_presets.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _activePreset?.id,
          isExpanded: true,
          dropdownColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF1976D2)),
          items: _presets.map((p) {
            return DropdownMenuItem(value: p.id, child: Text(p.name));
          }).toList(),
          onChanged: (value) {
            setState(() {
              final found = _presets.where((p) => p.id == value);
              _activePreset = found.isNotEmpty ? found.first : (_presets.isNotEmpty ? _presets.first : null);
            });
          },
        ),
      ),
    );
  }

  Widget _buildPlayButton(String lang) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: _activePreset != null ? _startGame : null,
        icon: const Icon(Icons.play_arrow_rounded, size: 24),
        label: const Text(
          'PLAY',
          style: TextStyle(
            fontSize: 16,
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
    );
  }

  Widget _buildPresetsButton(bool isDark, String lang) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: _openPresets,
        icon: const Icon(Icons.tune_rounded, size: 20),
        label: const Text(
          'PRESETS',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF1976D2),
          side: const BorderSide(color: Color(0xFF1976D2), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressButton(bool isDark, String lang) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: _openProgress,
        icon: const Icon(Icons.bar_chart_rounded, size: 20),
        label: const Text(
          'PROGRESS',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF2E7D32),
          side: const BorderSide(color: Color(0xFF2E7D32), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsButton(bool isDark, String lang) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: _openSettings,
        icon: const Icon(Icons.settings_rounded, size: 20),
        label: const Text(
          'SETTINGS',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
          side: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade400, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    if (secs == 0) return '${minutes}m';
    return '${minutes}m${secs}s';
  }
}
