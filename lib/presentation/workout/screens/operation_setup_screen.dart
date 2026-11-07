import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/localization/app_localizations.dart';
import 'package:mathall/presentation/custom_difficulty/widgets/preset_edit_dialog.dart';
import 'package:mathall/presentation/custom_difficulty/screens/custom_difficulty_screen.dart';
import 'workout_screen.dart';
import '../../arithmetic_memory/screens/arithmetic_memory_screen.dart';
import '../../custom_mixed/screens/custom_mixed_screen.dart';

class OperationSetupScreen extends StatefulWidget {
  final String operation;
  final bool? initialNegativeNumbersEnabled;

  const OperationSetupScreen({super.key, required this.operation, this.initialNegativeNumbersEnabled});

  @override
  State<OperationSetupScreen> createState() => _OperationSetupScreenState();
}

class _OperationSetupScreenState extends State<OperationSetupScreen> {
  final List<String> _availableTypes = [
    "Bulat",
    "Desimal",
    "Persentase",
    "Kuadrat",
    "Akar",
    "Pecahan"
  ];

  late List<String> _selectedTypes;
  late bool _localNegativeNumbersEnabled;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>().settings;
    _selectedTypes = List.from(settings.activeNumberTypes);
    if (_selectedTypes.isEmpty) {
      _selectedTypes = ["Bulat"];
    }
    _localNegativeNumbersEnabled = widget.initialNegativeNumbersEnabled ?? settings.isNegativeNumbersEnabled;
  }

  void _saveSettings() {
    final provider = context.read<SettingsProvider>();
    final newSettings = provider.settings.copyWith(
      activeNumberTypes: _selectedTypes,
    );
    provider.updateSettings(newSettings);
  }

  void _showSettingsDialog(BuildContext context, SettingsProvider provider) {
    final lang = provider.settings.language;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            final currentDiff = provider.settings.difficulty;
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                lang == 'English' ? 'Operation Settings' : 'Pengaturan Operasi',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Difficulty Selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          lang == 'English' ? 'Difficulty:' : 'Tingkat Kesulitan:',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        DropdownButton<String>(
                          value: ['Easy', 'Medium', 'Hard', 'Challenging', 'Expert', 'Extreme', 'Custom'].contains(currentDiff)
                              ? currentDiff
                              : 'Medium',
                          underline: const SizedBox(),
                          items: ['Easy', 'Medium', 'Hard', 'Challenging', 'Expert', 'Extreme', 'Custom'].map((e) {
                            String display = AppLocalizations.get(lang, e.toLowerCase());
                            return DropdownMenuItem(value: e, child: Text(display));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              provider.setDifficulty(val);
                              setStateDialog(() {});
                              setState(() {});
                            }
                          },
                        ),
                      ],
                    ),
                    const Divider(),
                    if (currentDiff == 'Custom') ...[
                      // 1-Variable Presets (Faktorial, Nilai Mutlak)
                      if (['Faktorial', 'Nilai Mutlak'].contains(widget.operation) ||
                          (widget.operation == 'Custom Mixed' && _selectedTypes.any((t) => ['Faktorial', 'Nilai Mutlak'].contains(t)))) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              lang == 'English' ? 'Preset (1 Variable):' : 'Preset (1 Variabel):',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            TextButton(
                              onPressed: () async {
                                await Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomDifficultyScreen()));
                                setStateDialog(() {});
                                setState(() {});
                              },
                              child: Text(lang == 'English' ? 'Manage' : 'Kelola', style: const TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: provider.settings.var1Presets.any((p) => p.id == provider.settings.activeVar1PresetId)
                                  ? provider.settings.activeVar1PresetId
                                  : (provider.settings.var1Presets.isNotEmpty ? provider.settings.var1Presets.first.id : null),
                              items: provider.settings.var1Presets.map((p) => DropdownMenuItem(
                                value: p.id,
                                child: Text('${p.name} (X: ${p.xDigit}d)', overflow: TextOverflow.ellipsis),
                              )).toList(),
                              onChanged: (id) {
                                if (id != null) {
                                  provider.setActiveVar1Preset(id);
                                  setStateDialog(() {});
                                  setState(() {});
                                }
                              },
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Digit X: ${provider.settings.activeVar1Preset.xDigit} digit', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                            TextButton.icon(
                              icon: const Icon(Icons.edit, size: 14),
                              label: Text(lang == 'English' ? 'Edit' : 'Ubah', style: const TextStyle(fontSize: 12)),
                              onPressed: () async {
                                await showEditPresetDialog(context, provider, provider.settings.activeVar1Preset, 1);
                                setStateDialog(() {});
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],

                      // 2-Variable Presets (Penjumlahan, Pengurangan, Perkalian, Pembagian, dll)
                      if (['Penjumlahan', 'Pengurangan', 'Perkalian', 'Pembagian', 'Penjumlahan & Pengurangan', 'Perkalian & Pembagian', 'Persentase', 'Modulo', 'Perbandingan', 'Desimal', 'Aritmetika Campuran'].contains(widget.operation) ||
                          (widget.operation == 'Custom Mixed' && _selectedTypes.any((t) => ['Penjumlahan', 'Pengurangan', 'Perkalian', 'Pembagian', 'Persentase', 'Modulo', 'Perbandingan', 'Desimal'].contains(t)))) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              lang == 'English' ? 'Preset (2 Variables):' : 'Preset (2 Variabel):',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            TextButton(
                              onPressed: () async {
                                await Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomDifficultyScreen()));
                                setStateDialog(() {});
                                setState(() {});
                              },
                              child: Text(lang == 'English' ? 'Manage' : 'Kelola', style: const TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: provider.settings.var2Presets.any((p) => p.id == provider.settings.activeVar2PresetId)
                                  ? provider.settings.activeVar2PresetId
                                  : (provider.settings.var2Presets.isNotEmpty ? provider.settings.var2Presets.first.id : null),
                              items: provider.settings.var2Presets.map((p) => DropdownMenuItem(
                                value: p.id,
                                child: Text('${p.name} (X:${p.xDigit}d, Y:${p.yDigit ?? p.xDigit}d${p.isSwappable ? ", SW" : ""})', overflow: TextOverflow.ellipsis),
                              )).toList(),
                              onChanged: (id) {
                                if (id != null) {
                                  provider.setActiveVar2Preset(id);
                                  setStateDialog(() {});
                                  setState(() {});
                                }
                              },
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('X=${provider.settings.activeVar2Preset.xDigit}d, Y=${provider.settings.activeVar2Preset.yDigit ?? 1}d${provider.settings.activeVar2Preset.isSwappable ? " (Swappable)" : ""}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                            TextButton.icon(
                              icon: const Icon(Icons.edit, size: 14),
                              label: Text(lang == 'English' ? 'Edit' : 'Ubah', style: const TextStyle(fontSize: 12)),
                              onPressed: () async {
                                await showEditPresetDialog(context, provider, provider.settings.activeVar2Preset, 2);
                                setStateDialog(() {});
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],

                      // Complex Numbers Presets (Akar, Pangkat, Logaritma)
                      if (['Akar', 'Pangkat', 'Logaritma'].contains(widget.operation) ||
                          (widget.operation == 'Custom Mixed' && _selectedTypes.any((t) => ['Akar', 'Kuadrat', 'Pecahan', 'Logaritma'].contains(t)))) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              lang == 'English' ? 'Preset (Complex Numbers):' : 'Preset (Akar/Pangkat/Log):',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            TextButton(
                              onPressed: () async {
                                await Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomDifficultyScreen()));
                                setStateDialog(() {});
                                setState(() {});
                              },
                              child: Text(lang == 'English' ? 'Manage' : 'Kelola', style: const TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: provider.settings.otherPresets.any((p) => p.id == provider.settings.activeOtherPresetId)
                                  ? provider.settings.activeOtherPresetId
                                  : (provider.settings.otherPresets.isNotEmpty ? provider.settings.otherPresets.first.id : null),
                              items: provider.settings.otherPresets.map((p) => DropdownMenuItem(
                                value: p.id,
                                child: Text('${p.name} (Pkt: ${p.pangkatLimit}, Akr: ${p.akarLimit})', overflow: TextOverflow.ellipsis),
                              )).toList(),
                              onChanged: (id) {
                                if (id != null) {
                                  provider.setActiveOtherPreset(id);
                                  setStateDialog(() {});
                                  setState(() {});
                                }
                              },
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Pangkat: Max ${provider.settings.activeOtherPreset.pangkatLimit}, Akar: Max ${provider.settings.activeOtherPreset.akarLimit}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                            TextButton.icon(
                              icon: const Icon(Icons.edit, size: 14),
                              label: Text(lang == 'English' ? 'Edit' : 'Ubah', style: const TextStyle(fontSize: 12)),
                              onPressed: () async {
                                await showEditPresetDialog(context, provider, provider.settings.activeOtherPreset, 3);
                                setStateDialog(() {});
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],

                      // Arithmetic Memory Presets
                      if (widget.operation == 'Arithmetic Memory' || widget.operation == 'Operasi Berantai') ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              lang == 'English' ? 'Preset (Arithmetic Memory):' : 'Preset (Operasi Berantai):',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            TextButton(
                              onPressed: () async {
                                await Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomDifficultyScreen()));
                                setStateDialog(() {});
                                setState(() {});
                              },
                              child: Text(lang == 'English' ? 'Manage' : 'Kelola', style: const TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: provider.settings.memoryPresets.any((p) => p.id == provider.settings.activeMemoryPresetId)
                                  ? provider.settings.activeMemoryPresetId
                                  : (provider.settings.memoryPresets.isNotEmpty ? provider.settings.memoryPresets.first.id : null),
                              items: provider.settings.memoryPresets.map((p) => DropdownMenuItem(
                                value: p.id,
                                child: Text(p.name, overflow: TextOverflow.ellipsis),
                              )).toList(),
                              onChanged: (id) {
                                if (id != null) {
                                  provider.setActiveMemoryPreset(id);
                                  setStateDialog(() {});
                                  setState(() {});
                                }
                              },
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Basis: ${provider.settings.activeMemoryPreset.baseDigit}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                            TextButton.icon(
                              icon: const Icon(Icons.edit, size: 14),
                              label: Text(lang == 'English' ? 'Edit' : 'Ubah', style: const TextStyle(fontSize: 12)),
                              onPressed: () async {
                                await showEditPresetDialog(context, provider, provider.settings.activeMemoryPreset, 4);
                                setStateDialog(() {});
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                      const Divider(),
                    ],
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(lang == 'English' ? "Negative Numbers" : "Bilangan Negatif", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text(lang == 'English' ? "Allow negative answers" : "Izinkan hasil negatif"),
                      value: _localNegativeNumbersEnabled,
                      onChanged: (val) {
                        setStateDialog(() {
                          _localNegativeNumbersEnabled = val;
                        });
                        provider.toggleNegativeNumbers(val);
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(lang == 'English' ? 'Close' : 'Tutup'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _getIcon(String type) {
    switch (type) {
      case "Bulat": return const Icon(Icons.looks_one, color: Colors.blue);
      case "Desimal": return const Icon(Icons.money, color: Colors.green);
      case "Persentase": return const Icon(Icons.percent, color: Colors.orange);
      case "Kuadrat": return const Icon(Icons.superscript, color: Colors.purple);
      case "Akar": return const Icon(Icons.square_foot, color: Colors.red);
      case "Pecahan": return const Icon(Icons.pie_chart_outline, color: Colors.teal);
      default: return const Icon(Icons.numbers);
    }
  }

  String _getSubtitle(String type, String lang) {
    switch (type) {
      case "Bulat": return lang == 'English' ? "e.g., 1, 5, 10" : "Misal: 1, 5, 10";
      case "Desimal": return lang == 'English' ? "e.g., 1.5, 3.14" : "Misal: 1.5, 3.14";
      case "Persentase": return lang == 'English' ? "e.g., 10%, 50%" : "Misal: 10%, 50%";
      case "Kuadrat": return lang == 'English' ? "e.g., 2², 5²" : "Misal: 2², 5²";
      case "Akar": return lang == 'English' ? "e.g., √9, √16" : "Misal: √9, √16";
      case "Pecahan": return lang == 'English' ? "e.g., 1/2, 3/4" : "Misal: 1/2, 3/4";
      default: return "";
    }
  }

  String _getPresetTitle(SettingsProvider prov) {
    if (['Faktorial', 'Nilai Mutlak'].contains(widget.operation)) {
      return 'Mode Custom Aktif: ${prov.settings.activeVar1Preset.name}';
    } else if (['Akar', 'Pangkat', 'Logaritma'].contains(widget.operation)) {
      return 'Mode Custom Aktif: ${prov.settings.activeOtherPreset.name}';
    } else if (widget.operation == 'Arithmetic Memory' || widget.operation == 'Operasi Berantai') {
      return 'Mode Custom Aktif: ${prov.settings.activeMemoryPreset.name}';
    } else {
      return 'Mode Custom Aktif: ${prov.settings.activeVar2Preset.name}';
    }
  }

  String _getPresetDetail(SettingsProvider prov) {
    if (['Faktorial', 'Nilai Mutlak'].contains(widget.operation)) {
      return 'X: ${prov.settings.activeVar1Preset.xDigit} digit';
    } else if (['Akar', 'Pangkat', 'Logaritma'].contains(widget.operation)) {
      final p = prov.settings.activeOtherPreset;
      return 'Pangkat: Max ${p.pangkatLimit}, Akar: Max ${p.akarLimit}';
    } else if (widget.operation == 'Arithmetic Memory' || widget.operation == 'Operasi Berantai') {
      return 'Basis: ${prov.settings.activeMemoryPreset.baseDigit}';
    } else {
      final p = prov.settings.activeVar2Preset;
      return 'X: ${p.xDigit} digit, Y: ${p.yDigit ?? p.xDigit} digit${p.isSwappable ? " (Swappable)" : ""}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<SettingsProvider>().settings.language;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.get(lang, widget.operation), style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0288D1),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _showSettingsDialog(context, context.read<SettingsProvider>());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Consumer<SettingsProvider>(
            builder: (context, prov, child) {
              if (prov.settings.difficulty != 'Custom') return const SizedBox.shrink();
              return Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE1F5FE),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF0288D1).withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.tune, color: Color(0xFF0288D1), size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getPresetTitle(prov),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF01579B)),
                          ),
                          Text(
                            _getPresetDetail(prov),
                            style: TextStyle(fontSize: 11, color: Colors.blueGrey.shade700),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
                      onPressed: () => _showSettingsDialog(context, prov),
                      child: Text(lang == 'English' ? 'Change' : 'Ganti', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0288D1))),
                    ),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: ListView.builder(
                  itemCount: _availableTypes.length,
                  itemBuilder: (context, index) {
                    final type = _availableTypes[index];
                    final isSelected = _selectedTypes.contains(type);
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 1,
                      child: SwitchListTile(
                        secondary: _getIcon(type),
                        title: Text(AppLocalizations.get(lang, type), style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(_getSubtitle(type, lang)),
                        value: isSelected,
                        onChanged: (val) {
                          setState(() {
                            if (val) {
                              _selectedTypes.add(type);
                            } else {
                              if (_selectedTypes.length > 1) {
                                _selectedTypes.remove(type);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(lang == 'English' ? "At least one type must be selected." : "Minimal satu tipe harus dipilih."),
                                  ),
                                );
                              }
                            }
                          });
                          _saveSettings();
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0288D1),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      _saveSettings();
                      if (widget.operation == "Arithmetic Memory" || widget.operation == "Operasi Berantai") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ArithmeticMemoryScreen()),
                        );
                      } else if (widget.operation == "Custom Mixed" || widget.operation == "Campuran Kustom") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CustomMixedScreen()),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WorkoutScreen(
                              operation: widget.operation,
                              overrideNegativeNumbers: _localNegativeNumbersEnabled,
                            ),
                          ),
                        );
                      }
                    },
                    child: Text(
                      lang == 'English' ? "START" : "MULAI",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
