import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'memory_game_screen.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../presentation/custom_difficulty/widgets/preset_edit_dialog.dart';

class ArithmeticMemoryScreen extends StatefulWidget {
  const ArithmeticMemoryScreen({super.key});

  @override
  State<ArithmeticMemoryScreen> createState() => _ArithmeticMemoryScreenState();
}

class _ArithmeticMemoryScreenState extends State<ArithmeticMemoryScreen> {
  String _selectedDifficulty = 'Easy';
  int _customSteps = 5;
  late TextEditingController _customStepsController;
  
  final Map<String, int> _difficultySteps = {
    'Easy': 5,
    'Medium': 10,
    'Hard': 20,
    'Extreme': 40,
    'Custom': 5,
  };

  @override
  void initState() {
    super.initState();
    _customStepsController = TextEditingController(text: _customSteps.toString());
  }

  @override
  void dispose() {
    _customStepsController.dispose();
    super.dispose();
  }

  void _showSettingsDialog(BuildContext context, SettingsProvider provider) {
    final lang = provider.settings.language;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            lang == 'English' ? 'Memory Settings' : 'Pengaturan Berantai',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(lang == 'English' ? 'Arithmetic Memory' : 'Operasi Berantai', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text(
                  provider.settings.memoryPresets.isNotEmpty
                      ? 'Preset Aktif: ${provider.settings.activeMemoryPreset.name}'
                      : (lang == 'English' ? 'No preset' : 'Tidak ada preset'),
                ),
                trailing: ElevatedButton(
                  onPressed: provider.settings.memoryPresets.isNotEmpty
                      ? () {
                          Navigator.pop(context);
                          showEditPresetDialog(context, provider, provider.settings.activeMemoryPreset, 4);
                        }
                      : null,
                  child: const Text('Edit'),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();
    final lang = provider.settings.language;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.get(lang, 'arithmetic_memory'), style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF0D6EFD),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsDialog(context, provider),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Spacer(),
              const Icon(Icons.memory, size: 60, color: Color(0xFF0D6EFD)),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.get(lang, 'select_difficulty'),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                lang == 'Indonesian' 
                  ? 'Hafalkan total perhitungan selagi operasi muncul di layar.' 
                  : 'Memorize the running total as operations flash on screen.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              _buildDiffButton('Easy', Colors.green, lang),
              const SizedBox(height: 12),
              _buildDiffButton('Medium', Colors.orange, lang),
              const SizedBox(height: 12),
              _buildDiffButton('Hard', Colors.redAccent, lang),
              const SizedBox(height: 12),
              _buildDiffButton('Extreme', Colors.purple, lang),
              const SizedBox(height: 12),
              _buildCustomDiffButton(Colors.blueGrey, lang),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D6EFD),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    int steps = _selectedDifficulty == 'Custom' ? _customSteps : _difficultySteps[_selectedDifficulty]!;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MemoryGameScreen(difficulty: _selectedDifficulty, steps: steps),
                      ),
                    );
                  },
                  child: const Text('START', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiffButton(String title, Color color, String lang) {
    final isSelected = _selectedDifficulty == title;
    final steps = _difficultySteps[title]!;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedDifficulty = title;
        });
      },
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: isSelected ? 2 : 1),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppLocalizations.get(lang, title.toLowerCase()), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : color)),
            Text('$steps ${lang == 'Indonesian' ? 'langkah' : 'steps'}', style: TextStyle(fontSize: 16, color: isSelected ? Colors.white : color)),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomDiffButton(Color color, String lang) {
    final isSelected = _selectedDifficulty == 'Custom';
    return InkWell(
      onTap: () {
        setState(() {
          _selectedDifficulty = 'Custom';
        });
      },
      child: Container(
        width: double.infinity,
        height: isSelected ? 120 : 60,
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: isSelected ? 2 : 1),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Custom', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : color)),
                if (!isSelected)
                  Text('...', style: TextStyle(fontSize: 16, color: isSelected ? Colors.white : color)),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(lang == 'Indonesian' ? 'Jumlah Langkah (Steps):' : 'Number of Steps:', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: _customStepsController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                      ),
                      onChanged: (val) {
                        final parsed = int.tryParse(val);
                        if (parsed != null && parsed > 0) {
                          _customSteps = parsed;
                        }
                      },
                    ),
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }
}
