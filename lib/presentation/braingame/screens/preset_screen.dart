// preset screen — CRUD presets dengan tombol "+"
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../models/preset.dart';
import '../services/preset_storage.dart';

class PresetScreen extends StatefulWidget {
  const PresetScreen({super.key});

  @override
  State<PresetScreen> createState() => _PresetScreenState();
}

class _PresetScreenState extends State<PresetScreen> {
  List<Preset> _presets = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPresets();
  }

  Future<void> _loadPresets() async {
    final presets = await PresetStorage.loadPresets();
    setState(() {
      _presets = presets;
      _loading = false;
    });
  }

  Future<void> _addPreset(String lang) async {
    if (_presets.length >= 10) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppLocalizations.get(lang, 'max_presets'))));
      return;
    }

    final newIndex = _presets.length + 1;
    final newPreset = Preset.defaultPreset(newIndex);

    // langsung buka editor
    final result = await _openEditor(newPreset, isNew: true);
    if (result != null) {
      await PresetStorage.addPreset(result);
      _loadPresets();
    }
  }

  Future<void> _editPreset(Preset preset) async {
    final result = await _openEditor(preset, isNew: false);
    if (result != null) {
      await PresetStorage.updatePreset(result);
      _loadPresets();
    }
  }

  Future<void> _deletePreset(Preset preset, String lang, bool isDark) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '${AppLocalizations.get(lang, 'delete')} ${preset.name}?',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          AppLocalizations.get(lang, 'delete_preset_desc'),
          style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade700),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              AppLocalizations.get(lang, 'cancel'),
              style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              AppLocalizations.get(lang, 'delete'),
              style: const TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await PresetStorage.deletePreset(preset.id);
      _loadPresets();
    }
  }

  Future<Preset?> _openEditor(Preset preset, {required bool isNew}) async {
    return Navigator.push<Preset>(
      context,
      MaterialPageRoute(
        builder: (_) => _PresetEditor(preset: preset, isNew: isNew),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = context.watch<SettingsProvider>().settings.language;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          AppLocalizations.get(lang, 'presets'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _presets.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _presets.length) {
                      return _buildAddButton(isDark, lang);
                    }
                    return _buildPresetCard(_presets[index], isDark, lang);
                  },
                ),
              ),
            ),
    );
  }

  Widget _buildPresetCard(Preset preset, bool isDark, String lang) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
      child: InkWell(
        onTap: () => _editPreset(preset),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF1976D2).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '${preset.nLevel}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      preset.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${preset.nLevel}-Back · '
                      '${preset.targetWins > 0 ? "${preset.targetWins} wins" : "∞"} · '
                      '${preset.timeLimitSeconds > 0 ? _formatTime(preset.timeLimitSeconds) : "∞"} · '
                      '${preset.sessionLength} trials',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              // delete
              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFD32F2F),
                  size: 22,
                ),
                onPressed: () => _deletePreset(preset, lang, isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton(bool isDark, String lang) {
    if (_presets.length >= 10) return const SizedBox();

    return Container(
      margin: const EdgeInsets.only(top: 8),
      height: 48,
      child: OutlinedButton.icon(
        onPressed: () => _addPreset(lang),
        icon: const Icon(Icons.add, size: 20),
        label: Text(
          AppLocalizations.get(lang, 'add_preset'),
          style: const TextStyle(
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

  String _formatTime(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    if (secs == 0) return '${minutes}m';
    return '${minutes}m${secs}s';
  }
}

// editor preset — setting N-level, target wins, time limit, session length
class _PresetEditor extends StatefulWidget {
  final Preset preset;
  final bool isNew;

  const _PresetEditor({required this.preset, required this.isNew});

  @override
  State<_PresetEditor> createState() => _PresetEditorState();
}

class _PresetEditorState extends State<_PresetEditor> {
  late TextEditingController _nameController;
  late TextEditingController _nLevelController;
  late TextEditingController _targetWinsController;
  late TextEditingController _timeLimitController;
  late TextEditingController _intervalController;
  late TextEditingController _sessionLengthController;

  late int _nLevel;
  late int _targetWins;
  late int _timeLimitMinutes;
  late int _sessionLength;
  late double _intervalSeconds;

  @override
  void initState() {
    super.initState();
    _nLevel = widget.preset.nLevel;
    _targetWins = widget.preset.targetWins;
    _timeLimitMinutes = widget.preset.timeLimitSeconds ~/ 60;
    _sessionLength = widget.preset.sessionLength;
    _intervalSeconds = widget.preset.intervalSeconds;

    _nameController = TextEditingController(text: widget.preset.name);
    _nLevelController = TextEditingController(text: '$_nLevel');
    _targetWinsController = TextEditingController(text: '$_targetWins');
    _timeLimitController = TextEditingController(text: '$_timeLimitMinutes');
    _intervalController = TextEditingController(text: '$_intervalSeconds');
    _sessionLengthController = TextEditingController(text: '$_sessionLength');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nLevelController.dispose();
    _targetWinsController.dispose();
    _timeLimitController.dispose();
    _intervalController.dispose();
    _sessionLengthController.dispose();
    super.dispose();
  }

  void _save() {
    final updated = widget.preset.copyWith(
      name: _nameController.text.trim().isEmpty
          ? widget.preset.name
          : _nameController.text.trim(),
      nLevel: _nLevel,
      targetWins: _targetWins,
      timeLimitSeconds: _timeLimitMinutes * 60,
      sessionLength: _sessionLength,
      intervalSeconds: _intervalSeconds,
    );
    Navigator.pop(context, updated);
  }

  void _cancel() {
    Navigator.pop(context, null);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = context.watch<SettingsProvider>().settings.language;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.isNew ? AppLocalizations.get(lang, 'new_preset') : AppLocalizations.get(lang, 'edit_preset'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: _cancel,
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(
              AppLocalizations.get(lang, 'save'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Preset name
                _buildLabel(AppLocalizations.get(lang, 'preset_name'), isDark),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.get(lang, 'preset_name_hint'),
                    hintStyle: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade400),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // N-Level
                _buildLabel(AppLocalizations.get(lang, 'n_level_desc'), isDark),
                const SizedBox(height: 4),
                Text(
                  '${AppLocalizations.get(lang, 'current_level')} $_nLevel-Back',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1976D2),
                  ),
                ),
                Slider(
                  value: _nLevel.toDouble().clamp(1, 100),
                  min: 1,
                  max: 100,
                  divisions: 99,
                  activeColor: const Color(0xFF1976D2),
                  label: '$_nLevel',
                  onChanged: (val) {
                    setState(() {
                      _nLevel = val.round();
                      _nLevelController.text = '$_nLevel';
                    });
                  },
                ),
                _buildManualInput(
                  controller: _nLevelController,
                  isDark: isDark,
                  onChanged: (val) {
                    final n = int.tryParse(val);
                    if (n != null && n >= 1) {
                      setState(() => _nLevel = n);
                    }
                  },
                ),

                const SizedBox(height: 28),

                // Target Wins
                _buildLabel(AppLocalizations.get(lang, 'target_wins_desc'), isDark),
                const SizedBox(height: 4),
                Text(
                  _targetWins > 0 ? '$_targetWins' : '∞',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1976D2),
                  ),
                ),
                Slider(
                  value: _targetWins.toDouble().clamp(0, 100),
                  min: 0,
                  max: 100,
                  divisions: 100,
                  activeColor: const Color(0xFF1976D2),
                  label: _targetWins > 0 ? '$_targetWins' : '∞',
                  onChanged: (val) {
                    setState(() {
                      _targetWins = val.round();
                      _targetWinsController.text = '$_targetWins';
                      if (_targetWins > 0) {
                        _timeLimitMinutes = 0;
                        _timeLimitController.text = '0';
                      }
                    });
                  },
                ),
                _buildManualInput(
                  controller: _targetWinsController,
                  isDark: isDark,
                  onChanged: (val) {
                    final n = int.tryParse(val);
                    if (n != null && n >= 0) {
                      setState(() {
                        _targetWins = n;
                        if (_targetWins > 0) {
                          _timeLimitMinutes = 0;
                          _timeLimitController.text = '0';
                        }
                      });
                    }
                  },
                ),

                const SizedBox(height: 28),

                // Time Limit
                _buildLabel(AppLocalizations.get(lang, 'time_limit_desc'), isDark),
                const SizedBox(height: 4),
                Text(
                  _timeLimitMinutes > 0 ? '$_timeLimitMinutes m' : '∞',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1976D2),
                  ),
                ),
                Slider(
                  value: _timeLimitMinutes.toDouble().clamp(0, 60),
                  min: 0,
                  max: 60,
                  divisions: 60,
                  activeColor: const Color(0xFF1976D2),
                  label: _timeLimitMinutes > 0 ? '${_timeLimitMinutes}m' : '∞',
                  onChanged: (val) {
                    setState(() {
                      _timeLimitMinutes = val.round();
                      _timeLimitController.text = '$_timeLimitMinutes';
                      if (_timeLimitMinutes > 0) {
                        _targetWins = 0;
                        _targetWinsController.text = '0';
                      }
                    });
                  },
                ),
                _buildManualInput(
                  controller: _timeLimitController,
                  isDark: isDark,
                  onChanged: (val) {
                    final n = int.tryParse(val);
                    if (n != null && n >= 0) {
                      setState(() {
                        _timeLimitMinutes = n;
                        if (_timeLimitMinutes > 0) {
                          _targetWins = 0;
                          _targetWinsController.text = '0';
                        }
                      });
                    }
                  },
                ),

                const SizedBox(height: 28),

                // Interval
                _buildLabel(AppLocalizations.get(lang, 'interval_desc'), isDark),
                const SizedBox(height: 4),
                Text(
                  _intervalSeconds > 0 ? '${_intervalSeconds}s' : 'Manual',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1976D2),
                  ),
                ),
                Slider(
                  value: _intervalSeconds.clamp(0.0, 10.0),
                  min: 0,
                  max: 10,
                  divisions: 20,
                  activeColor: const Color(0xFF1976D2),
                  label: _intervalSeconds > 0 ? '${_intervalSeconds}s' : 'Manual',
                  onChanged: (val) {
                    setState(() {
                      _intervalSeconds = val;
                      _intervalController.text = '$_intervalSeconds';
                    });
                  },
                ),
                _buildManualInput(
                  controller: _intervalController,
                  isDark: isDark,
                  onChanged: (val) {
                    final n = double.tryParse(val);
                    if (n != null && n >= 0) {
                      setState(() => _intervalSeconds = n);
                    }
                  },
                ),

                const SizedBox(height: 28),

                // Session Length
                _buildLabel(AppLocalizations.get(lang, 'session_length_desc'), isDark),
                const SizedBox(height: 4),
                Text(
                  '$_sessionLength trials',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1976D2),
                  ),
                ),
                Slider(
                  value: _sessionLength.toDouble().clamp(10, 200),
                  min: 10,
                  max: 200,
                  divisions: 190,
                  activeColor: const Color(0xFF1976D2),
                  label: '$_sessionLength',
                  onChanged: (val) {
                    setState(() {
                      _sessionLength = val.round();
                      _sessionLengthController.text = '$_sessionLength';
                    });
                  },
                ),
                _buildManualInput(
                  controller: _sessionLengthController,
                  isDark: isDark,
                  onChanged: (val) {
                    final n = int.tryParse(val);
                    if (n != null && n >= 1) {
                      setState(() => _sessionLength = n);
                    }
                  },
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, bool isDark) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
      ),
    );
  }

  Widget _buildManualInput({
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    required bool isDark,
  }) {
    return SizedBox(
      height: 42,
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          filled: true,
          fillColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
