import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../workout/screens/workout_screen.dart';
import '../../custom_difficulty/widgets/preset_edit_dialog.dart';

class CustomMixedScreen extends StatefulWidget {
  const CustomMixedScreen({super.key});

  @override
  State<CustomMixedScreen> createState() => _CustomMixedScreenState();
}

class _CustomMixedScreenState extends State<CustomMixedScreen> {
  final List<String> _availableTopics = [
    "Penjumlahan",
    "Pengurangan",
    "Perkalian",
    "Pembagian",
    "Pangkat",
    "Akar",
    "Persentase",
    "Faktorial",
    "Nilai Mutlak",
    "Logaritma",
    "Modulo"
  ];

  final List<String> _availableTypes = [
    "Bulat",
    "Desimal",
    "Persentase",
    "Kuadrat",
    "Akar",
    "Pecahan"
  ];

  late List<String> _selectedTopics;
  late List<String> _selectedTypes;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>().settings;
    _selectedTopics = List.from(settings.customMixedOperations);
    if (_selectedTopics.isEmpty) {
      _selectedTopics = ["Penjumlahan", "Pengurangan", "Perkalian", "Pembagian"];
    }
    _selectedTypes = List.from(settings.activeNumberTypes);
    if (_selectedTypes.isEmpty) {
      _selectedTypes = ["Bulat"];
    }
  }

  void _saveSettings() {
    final provider = context.read<SettingsProvider>();
    final newSettings = provider.settings.copyWith(
      customMixedOperations: _selectedTopics,
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
            bool localNegative = provider.settings.isNegativeNumbersEnabled;
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
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(lang == 'English' ? 'Single Variable Numbers' : 'Angka Satu Variabel', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        subtitle: Text(
                          provider.settings.var1Presets.isNotEmpty
                              ? 'Preset Aktif: ${provider.settings.activeVar1Preset.name}'
                              : (lang == 'English' ? 'No preset' : 'Tidak ada preset'),
                        ),
                        trailing: ElevatedButton(
                          onPressed: provider.settings.var1Presets.isNotEmpty
                              ? () {
                                  Navigator.pop(context);
                                  showEditPresetDialog(context, provider, provider.settings.activeVar1Preset, 1);
                                }
                              : null,
                          child: const Text('Edit'),
                        ),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(lang == 'English' ? 'Standard Numbers (2 Variables)' : 'Angka Standar (2 Variabel)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        subtitle: Text(
                          provider.settings.var2Presets.isNotEmpty
                              ? 'Preset Aktif: ${provider.settings.activeVar2Preset.name}'
                              : (lang == 'English' ? 'No preset' : 'Tidak ada preset'),
                        ),
                        trailing: ElevatedButton(
                          onPressed: provider.settings.var2Presets.isNotEmpty
                              ? () {
                                  Navigator.pop(context);
                                  showEditPresetDialog(context, provider, provider.settings.activeVar2Preset, 2);
                                }
                              : null,
                          child: const Text('Edit'),
                        ),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(lang == 'English' ? 'Complex Numbers (Roots, Powers, Log)' : 'Angka Kompleks (Akar, Pangkat, Logaritma)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        subtitle: Text(
                          provider.settings.otherPresets.isNotEmpty
                              ? 'Preset Aktif: ${provider.settings.activeOtherPreset.name}'
                              : (lang == 'English' ? 'No preset' : 'Tidak ada preset'),
                        ),
                        trailing: ElevatedButton(
                          onPressed: provider.settings.otherPresets.isNotEmpty
                              ? () {
                                  Navigator.pop(context);
                                  showEditPresetDialog(context, provider, provider.settings.activeOtherPreset, 3);
                                }
                              : null,
                          child: const Text('Edit'),
                        ),
                      ),
                      const Divider(),
                    ],
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(lang == 'English' ? "Negative Numbers" : "Bilangan Negatif", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text(lang == 'English' ? "Allow negative answers" : "Izinkan hasil negatif"),
                      value: localNegative,
                      onChanged: (val) {
                        setStateDialog(() {
                          localNegative = val;
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
          }
        );
      },
    );
  }

  Widget _getTopicIcon(String topic) {
    switch (topic) {
      case "Penjumlahan": return const Icon(Icons.add, color: Colors.blue);
      case "Pengurangan": return const Icon(Icons.remove, color: Colors.indigo);
      case "Perkalian": return const Icon(Icons.close, color: Colors.amber);
      case "Pembagian": return const Icon(Icons.safety_divider, color: Colors.teal);
      case "Pangkat": return const Icon(Icons.superscript, color: Colors.purple);
      case "Akar": return const Icon(Icons.square_foot, color: Colors.red);
      case "Persentase": return const Icon(Icons.percent, color: Colors.orange);
      case "Faktorial": return const Icon(Icons.priority_high, color: Colors.deepOrange);
      case "Nilai Mutlak": return const Icon(Icons.compare_arrows, color: Colors.pink);
      case "Logaritma": return const Icon(Icons.functions, color: Colors.deepPurple);
      case "Modulo": return const Icon(Icons.sync_alt, color: Colors.cyan);
      default: return const Icon(Icons.calculate);
    }
  }

  String _getTopicSubtitle(String topic, String lang) {
    switch (topic) {
      case "Penjumlahan": return "Contoh: 12 + 34";
      case "Pengurangan": return "Contoh: 56 - 23";
      case "Perkalian": return "Contoh: 7 × 8";
      case "Pembagian": return "Contoh: 72 ÷ 8";
      case "Pangkat": return "Contoh: 2³ = 8";
      case "Akar": return "Contoh: √64 = 8";
      case "Persentase": return "Contoh: 20% × 50";
      case "Faktorial": return "Contoh: 5! = 120";
      case "Nilai Mutlak": return "Contoh: |-15| = 15";
      case "Logaritma": return "Contoh: log_2(16) = 4";
      case "Modulo": return "Contoh: 17 mod 5 = 2";
      default: return "";
    }
  }

  Widget _getTypeIcon(String type) {
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

  String _getTypeSubtitle(String type, String lang) {
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

  @override
  Widget build(BuildContext context) {
    final settingsProv = context.watch<SettingsProvider>();
    final lang = settingsProv.settings.language;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.get(lang, "Custom Mixed")),
          bottom: TabBar(
            tabs: [
              Tab(
                icon: const Icon(Icons.sports_esports),
                text: lang == 'English' ? '1. Math Games' : '1. Operasi Math',
              ),
              Tab(
                icon: const Icon(Icons.format_list_numbered),
                text: lang == 'English' ? '2. Number Formats' : '2. Format Angka',
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => _showSettingsDialog(context, settingsProv),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  // Tab 1: Operasi Matematika
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _availableTopics.length,
                        itemBuilder: (context, index) {
                          final topic = _availableTopics[index];
                          final isSelected = _selectedTopics.contains(topic);
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            elevation: 1,
                            child: SwitchListTile(
                              secondary: _getTopicIcon(topic),
                              title: Text(
                                AppLocalizations.get(lang, topic),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                _getTopicSubtitle(topic, lang),
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                              ),
                              value: isSelected,
                              onChanged: (val) {
                                setState(() {
                                  if (val) {
                                    _selectedTopics.add(topic);
                                  } else {
                                    if (_selectedTopics.length > 1) {
                                      _selectedTopics.remove(topic);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(lang == 'English' ? "At least one game must be selected." : "Minimal satu operasi harus dipilih."),
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

                  // Tab 2: Format / Tipe Angka (Bulat, Desimal, Kuadrat, Akar, Pecahan)
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _availableTypes.length,
                        itemBuilder: (context, index) {
                          final type = _availableTypes[index];
                          final isSelected = _selectedTypes.contains(type);
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            elevation: 1,
                            child: SwitchListTile(
                              secondary: _getTypeIcon(type),
                              title: Text(
                                AppLocalizations.get(lang, type),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                _getTypeSubtitle(type, lang),
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                              ),
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
                                          content: Text(lang == 'English' ? "At least one number type must be selected." : "Minimal satu tipe angka harus dipilih."),
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
                ],
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
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const WorkoutScreen(operation: "Custom Mixed"),
                          ),
                        );
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
      ),
    );
  }
}
