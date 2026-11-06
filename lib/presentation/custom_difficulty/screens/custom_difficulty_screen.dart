import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mathall/core/providers/settings_provider.dart';
import 'package:mathall/data/models/app_settings.dart';
import 'package:mathall/presentation/custom_difficulty/widgets/preset_edit_dialog.dart';
import 'package:mathall/presentation/custom_difficulty/widgets/live_question_preview.dart';
import 'dart:math';

class CustomDifficultyScreen extends StatelessWidget {
  const CustomDifficultyScreen({super.key});

  void _showAddPresetDialog(BuildContext context, SettingsProvider provider) {
    int selectedVarType =
        2; // 2 for 'Operasi 2 Variabel', 1 for 'Operasi 1 Variabel', 3 for 'Lain-Lain', 4 for 'Berantai'
    String name = '';
    int xDigit = 1;
    int yDigit = 1;
    int baseDigit = 10;
    int akarLimit = 10;
    int pangkatLimit = 5;
    bool isSwappable = false;
    bool allowAkar = false;
    bool allowPangkat = false;
    bool allowPecahan = false;
    bool allowDesimal = false;
    bool allowPersentase = false;
    bool allowFaktorial = false;
    bool allowMutlak = false;
    bool allowLogaritma = false;
    bool allowModulo = false;
    bool allowNegative = false;
    bool isCampuranLainLain = false;
    bool allowCampuranAddSub = true;
    bool allowCampuranMulDiv = true;
    int? decimalPlaces = 1;
    bool isRandomDecimalDigits = false;
    int? maxThreshold = 505;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Buat Preset Baru',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Pilih Jenis Operasi',
                        border: OutlineInputBorder(),
                      ),
                      initialValue: selectedVarType,
                      items: const [
                        DropdownMenuItem(
                          value: 2,
                          child: Text('Operasi 2 Variabel (X dan Y)', overflow: TextOverflow.ellipsis),
                        ),
                        DropdownMenuItem(
                          value: 1,
                          child: Text('Operasi 1 Variabel (X saja)', overflow: TextOverflow.ellipsis),
                        ),
                        DropdownMenuItem(
                          value: 3,
                          child: Text('Complex Numbers (Akar & Pangkat)', overflow: TextOverflow.ellipsis),
                        ),
                        DropdownMenuItem(
                          value: 4,
                          child: Text('Berantai (Arithmetic Memory)', overflow: TextOverflow.ellipsis),
                        ),
                      ],
                      isExpanded: true,
                      onChanged: (val) {
                        setState(() => selectedVarType = val!);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Nama Preset (opsional)',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) => name = val,
                    ),
                    const SizedBox(height: 24),
                    if (selectedVarType == 1) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'X Digit:',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(width: 8),
                          DropdownButton<int>(
                            value: xDigit,
                            items: List.generate(10, (i) => i + 1)
                                .map((e) => DropdownMenuItem(value: e, child: Text('$e Digit')))
                                .toList(),
                            onChanged: (val) {
                              setState(() => xDigit = val!);
                            },
                          ),
                        ],
                      ),
                    ] else if (selectedVarType == 2) ...[
                      SwitchListTile(
                        title: const Text('Switch X,Y', style: TextStyle(fontWeight: FontWeight.w600)),
                        value: isSwappable,
                        onChanged: (val) {
                          setState(() => isSwappable = val);
                        },
                        contentPadding: EdgeInsets.zero,
                        activeTrackColor: const Color(0xFF1976D2).withValues(alpha: 0.5),
                        activeThumbColor: const Color(0xFF1976D2),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'X Digit:',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(width: 8),
                          DropdownButton<int>(
                            value: xDigit,
                            items: List.generate(10, (i) => i + 1)
                                .map((e) => DropdownMenuItem(value: e, child: Text('$e Digit')))
                                .toList(),
                            onChanged: (val) {
                              setState(() => xDigit = val!);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'Y Digit:',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(width: 8),
                          DropdownButton<int>(
                            value: yDigit,
                            items: List.generate(10, (i) => i + 1)
                                .map((e) => DropdownMenuItem(value: e, child: Text('$e Digit')))
                                .toList(),
                            onChanged: (val) {
                              setState(() => yDigit = val!);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'Batas Desimal (Precision):',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(width: 8),
                          DropdownButton<int>(
                            value: decimalPlaces ?? 1,
                            items: [1, 2, 3, 4, 5]
                                .map((e) => DropdownMenuItem(value: e, child: Text('$e Digit')))
                                .toList(),
                            onChanged: (val) {
                              setState(() => decimalPlaces = val);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Acak Digit Belakang Koma', style: TextStyle(fontWeight: FontWeight.w600)),
                                Text(
                                  'Variasi 1 s/d ${decimalPlaces ?? 1} digit (misal: 0.70 + 0.456)',
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: isRandomDecimalDigits,
                            onChanged: (val) => setState(() => isRandomDecimalDigits = val),
                          ),
                        ],
                      ),
                    ] else if (selectedVarType == 3) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'Batas Angka Dasar:',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(width: 8),
                          DropdownButton<int>(
                            value: baseDigit,
                            items: [9, 10, 20, 30, 40, 50, 100, 200, 500, 1000]
                                .map((e) => DropdownMenuItem(value: e, child: Text(e == 9 ? '1 Digit (Max 9)' : 'Max $e')))
                                .toList(),
                            onChanged: (val) {
                              setState(() => baseDigit = val!);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'Batas Limit Pangkat:',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(width: 8),
                          DropdownButton<int>(
                            value: pangkatLimit,
                            items: List.generate(10, (i) => i + 1)
                                .map((e) => DropdownMenuItem(value: e, child: Text('Max $e')))
                                .toList(),
                            onChanged: (val) {
                              setState(() => pangkatLimit = val!);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'Batas Limit Akar:',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(width: 8),
                          DropdownButton<int>(
                            value: akarLimit,
                            items: List.generate(20, (i) => i + 1)
                                .map((e) => DropdownMenuItem(value: e, child: Text('Max $e')))
                                .toList(),
                            onChanged: (val) {
                              setState(() => akarLimit = val!);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        title: const Text('Bentuk Campuran'),
                        subtitle: const Text('Contoh: 3√25 + 2√25', style: TextStyle(fontSize: 12)),
                        value: isCampuranLainLain,
                        onChanged: (val) => setState(() => isCampuranLainLain = val),
                        contentPadding: EdgeInsets.zero,
                      ),
                      if (isCampuranLainLain) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Pilihan Operasi Campuran:',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: FilterChip(
                                      selected: allowCampuranAddSub,
                                      label: const Center(
                                        child: Text('+  /  -', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      ),
                                      onSelected: (val) {
                                        setState(() {
                                          if (!val && !allowCampuranMulDiv) return;
                                          allowCampuranAddSub = val;
                                        });
                                      },
                                      selectedColor: Colors.blue.shade200,
                                      checkmarkColor: Colors.blue.shade900,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: FilterChip(
                                      selected: allowCampuranMulDiv,
                                      label: const Center(
                                        child: Text('×  /  ÷', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      ),
                                      onSelected: (val) {
                                        setState(() {
                                          if (!val && !allowCampuranAddSub) return;
                                          allowCampuranMulDiv = val;
                                        });
                                      },
                                      selectedColor: Colors.blue.shade200,
                                      checkmarkColor: Colors.blue.shade900,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ] else if (selectedVarType == 4) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(child: Text('Start Number Max:', style: TextStyle(fontWeight: FontWeight.w600))),
                          const SizedBox(width: 8),
                          DropdownButton<int>(
                            value: baseDigit,
                            items: [10, 20, 30, 40, 50, 100, 200, 500, 1000].map((e) => DropdownMenuItem(value: e, child: Text('Max $e'))).toList(),
                            onChanged: (val) { setState(() => baseDigit = val!); },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        title: const Text('Izinkan Bilangan Negatif'),
                        value: allowNegative,
                        onChanged: (val) => setState(() => allowNegative = val),
                        contentPadding: EdgeInsets.zero,
                      ),
                      SwitchListTile(
                        title: const Text('Izinkan Desimal'),
                        value: allowDesimal,
                        onChanged: (val) => setState(() => allowDesimal = val),
                        contentPadding: EdgeInsets.zero,
                      ),
                      SwitchListTile(
                        title: const Text('Izinkan Pecahan'),
                        value: allowPecahan,
                        onChanged: (val) => setState(() => allowPecahan = val),
                        contentPadding: EdgeInsets.zero,
                      ),
                      SwitchListTile(
                        title: const Text('Izinkan Persentase'),
                        value: allowPersentase,
                        onChanged: (val) => setState(() => allowPersentase = val),
                        contentPadding: EdgeInsets.zero,
                      ),
                      SwitchListTile(
                        title: const Text('Izinkan Akar'),
                        value: allowAkar,
                        onChanged: (val) => setState(() => allowAkar = val),
                        contentPadding: EdgeInsets.zero,
                      ),
                      SwitchListTile(
                        title: const Text('Izinkan Pangkat'),
                        value: allowPangkat,
                        onChanged: (val) => setState(() => allowPangkat = val),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                    LiveQuestionPreview(
                      presetType: selectedVarType,
                      xDigit: xDigit,
                      yDigit: selectedVarType == 2 ? yDigit : null,
                      baseDigit: (selectedVarType == 3 || selectedVarType == 4) ? baseDigit : null,
                      akarLimit: selectedVarType == 3 ? akarLimit : null,
                      pangkatLimit: selectedVarType == 3 ? pangkatLimit : null,
                      decimalPlaces: selectedVarType == 2 ? decimalPlaces : null,
                      isRandomDecimalDigits: selectedVarType == 2 ? isRandomDecimalDigits : false,
                      maxThreshold: (selectedVarType == 1 || selectedVarType == 2 || selectedVarType == 4) ? maxThreshold : null,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Batal',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    final presetName = name.trim().isEmpty
                        ? 'Preset ${Random().nextInt(1000)}'
                        : name.trim();
                    final newPreset = CustomPreset(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: presetName,
                      xDigit: (selectedVarType == 1 || selectedVarType == 2 || selectedVarType == 4) ? xDigit : 1,
                      yDigit: selectedVarType == 2 ? yDigit : null,
                      baseDigit: (selectedVarType == 3 || selectedVarType == 4) ? baseDigit : null,
                      akarLimit: selectedVarType == 3 ? akarLimit : null,
                      pangkatLimit: selectedVarType == 3 ? pangkatLimit : null,
                      isSwappable: selectedVarType == 2 ? isSwappable : false,
                      allowAkar: selectedVarType == 4 ? allowAkar : false,
                      allowPangkat: selectedVarType == 4 ? allowPangkat : false,
                      allowPecahan: selectedVarType == 4 ? allowPecahan : false,
                      allowDesimal: selectedVarType == 4 ? allowDesimal : false,
                      allowPersentase: selectedVarType == 4 ? allowPersentase : false,
                      allowFaktorial: selectedVarType == 4 ? allowFaktorial : false,
                      allowMutlak: selectedVarType == 4 ? allowMutlak : false,
                      allowLogaritma: selectedVarType == 4 ? allowLogaritma : false,
                      allowModulo: selectedVarType == 4 ? allowModulo : false,
                      allowNegative: selectedVarType == 4 ? allowNegative : false,
                      isCampuranLainLain: selectedVarType == 3 ? isCampuranLainLain : false,
                      allowCampuranAddSub: selectedVarType == 3 ? allowCampuranAddSub : true,
                      allowCampuranMulDiv: selectedVarType == 3 ? allowCampuranMulDiv : true,
                      decimalPlaces: selectedVarType == 2 ? decimalPlaces : null,
                      isRandomDecimalDigits: selectedVarType == 2 ? isRandomDecimalDigits : false,
                      maxThreshold: (selectedVarType == 1 || selectedVarType == 2 || selectedVarType == 4) ? maxThreshold : null,
                    );

                    if (selectedVarType == 1) {
                      provider.addVar1Preset(newPreset);
                      provider.setActiveVar1Preset(newPreset.id);
                    } else if (selectedVarType == 2) {
                      provider.addVar2Preset(newPreset);
                      provider.setActiveVar2Preset(newPreset.id);
                    } else if (selectedVarType == 3) {
                      provider.addOtherPreset(newPreset);
                      provider.setActiveOtherPreset(newPreset.id);
                    } else if (selectedVarType == 4) {
                      provider.addMemoryPreset(newPreset);
                      provider.setActiveMemoryPreset(newPreset.id);
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Simpan Preset'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();
    final settings = provider.settings;

    // activeV1 is actually 1-Variable operation presets
    final activeV1 = settings.var1Presets.firstWhere(
      (p) => p.id == settings.activeVar1PresetId,
      orElse: () => settings.var1Presets.isNotEmpty
          ? settings.var1Presets.first
          : CustomPreset(id: 'dummy', name: 'None', xDigit: 1),
    );
    final activeV2 = settings.var2Presets.firstWhere(
      (p) => p.id == settings.activeVar2PresetId,
      orElse: () => settings.var2Presets.isNotEmpty
          ? settings.var2Presets.first
          : CustomPreset(id: 'dummy', name: 'None', xDigit: 1, yDigit: 1),
    );
    final activeOther = settings.otherPresets.firstWhere(
      (p) => p.id == settings.activeOtherPresetId,
      orElse: () => settings.otherPresets.isNotEmpty
          ? settings.otherPresets.first
          : CustomPreset(id: 'dummy', name: 'None', xDigit: 1, baseDigit: 10, akarLimit: 20, pangkatLimit: 5),
    );
    final activeMemory = settings.memoryPresets.firstWhere(
      (p) => p.id == settings.activeMemoryPresetId,
      orElse: () => settings.memoryPresets.isNotEmpty
          ? settings.memoryPresets.first
          : CustomPreset(id: 'dummy', name: 'None', xDigit: 1, baseDigit: 100),
    );

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 768;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF0288D1),
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Custom Difficulty',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : const Color(0xFF101828),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Atur dan pilih preset untuk Operasi Matematika',
                            style: TextStyle(
                              fontSize: 15,
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: settings.difficulty == 'Custom'
                                  ? (isDark ? const Color(0xFF1B3B22) : const Color(0xFFE8F5E9))
                                  : (isDark ? const Color(0xFF3E2723) : const Color(0xFFFFF8E1)),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: settings.difficulty == 'Custom'
                                    ? (isDark ? Colors.green.shade700 : Colors.green.shade300)
                                    : (isDark ? Colors.amber.shade700 : Colors.amber.shade300),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  settings.difficulty == 'Custom' ? Icons.check_circle : Icons.info_outline,
                                  size: 14,
                                  color: settings.difficulty == 'Custom'
                                      ? (isDark ? Colors.green.shade300 : Colors.green.shade800)
                                      : (isDark ? Colors.amber.shade300 : Colors.amber.shade900),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    settings.difficulty == 'Custom'
                                        ? 'Mode Custom sedang Aktif untuk latihan game'
                                        : 'Mode saat ini: ${settings.difficulty} (Ketuk salah satu preset untuk mengaktifkan Custom)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: settings.difficulty == 'Custom'
                                          ? (isDark ? Colors.green.shade300 : Colors.green.shade900)
                                          : (isDark ? Colors.amber.shade300 : Colors.amber.shade900),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _showAddPresetDialog(context, provider),
                      icon: Icon(
                        Icons.add_circle,
                        color: isDark ? const Color(0xFF80D8FF) : const Color(0xFF0288D1),
                      ),
                      label: Text(
                        'Buat Preset Baru',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFF80D8FF) : const Color(0xFF0288D1),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: isDark ? const Color(0xFF80D8FF) : const Color(0xFF0288D1)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                if (isDesktop)
                  Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildVariableColumn(
                              context,
                              provider,
                              2, // 2 Variabel
                              settings.var2Presets,
                              activeV2.id,
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _buildVariableColumn(
                              context,
                              provider,
                              1, // 1 Variabel
                              settings.var1Presets,
                              activeV1.id,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildVariableColumn(
                              context,
                              provider,
                              3, // Lain-Lain
                              settings.otherPresets,
                              activeOther.id,
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _buildVariableColumn(
                              context,
                              provider,
                              4, // Memory
                              settings.memoryPresets,
                              activeMemory.id,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildVariableColumn(
                        context,
                        provider,
                        2,
                        settings.var2Presets,
                        activeV2.id,
                      ),
                      const SizedBox(height: 24),
                      _buildVariableColumn(
                        context,
                        provider,
                        1,
                        settings.var1Presets,
                        activeV1.id,
                      ),
                      const SizedBox(height: 24),
                      _buildVariableColumn(
                        context,
                        provider,
                        3,
                        settings.otherPresets,
                        activeOther.id,
                      ),
                      const SizedBox(height: 24),
                      _buildVariableColumn(
                        context,
                        provider,
                        4,
                        settings.memoryPresets,
                        activeMemory.id,
                      ),
                    ],
                  ),
                const SizedBox(height: 32),
                _buildBottomPanel(context, activeV1, activeV2, activeOther, activeMemory),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVariableColumn(
    BuildContext context,
    SettingsProvider provider,
    int presetType,
    List<CustomPreset> presets,
    String activeId,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String title = 'Operasi';
    String subtitle = '';
    Color themeColor = const Color(0xFF1976D2);
    Color headerBgColor = const Color(0xFFF3F8FF);

    if (presetType == 1) {
      title = 'Operasi 1 Variabel';
      subtitle = 'Faktorial, Nilai Mutlak';
      themeColor = const Color(0xFF2E7D32);
      headerBgColor = isDark ? const Color(0xFF1E3A20) : const Color(0xFFF1F8F1);
    } else if (presetType == 2) {
      title = 'Operasi 2 Variabel';
      subtitle = 'Penjumlahan, Pengurangan, dll.';
      themeColor = const Color(0xFF1976D2);
      headerBgColor = isDark ? const Color(0xFF162C46) : const Color(0xFFF3F8FF);
    } else if (presetType == 3) {
      title = 'Complex Numbers';
      subtitle = 'Akar, Pangkat, Logaritma';
      themeColor = const Color(0xFFE65100);
      headerBgColor = isDark ? const Color(0xFF3E2310) : const Color(0xFFFFF3E0);
    } else {
      title = 'Berantai';
      subtitle = 'Arithmetic Memory';
      themeColor = const Color(0xFF6A1B9A);
      headerBgColor = isDark ? const Color(0xFF2E153E) : const Color(0xFFF3E5F5);
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: headerBgColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
              border: Border(bottom: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : themeColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Preset Tersedia',
                  style: TextStyle(
                    fontWeight: FontWeight.w700, 
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                ...presets.map(
                  (preset) => _buildPresetItem(
                    context,
                    provider,
                    preset,
                    activeId == preset.id,
                    presetType,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, SettingsProvider provider, CustomPreset preset, int presetType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Preset'),
        content: Text('Apakah Anda yakin ingin menghapus preset "${preset.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              if (presetType == 1) {
                provider.removeVar1Preset(preset.id);
              } else if (presetType == 2) {
                provider.removeVar2Preset(preset.id);
              } else if (presetType == 3) {
                provider.removeOtherPreset(preset.id);
              } else if (presetType == 4) {
                provider.removeMemoryPreset(preset.id);
              }
              Navigator.pop(context);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }


  Widget _buildPresetItem(
    BuildContext context,
    SettingsProvider provider,
    CustomPreset preset,
    bool isActive,
    int presetType,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color themeColor = const Color(0xFF1976D2);
    if (presetType == 1) themeColor = const Color(0xFF2E7D32);
    if (presetType == 3) themeColor = const Color(0xFFE65100);
    if (presetType == 4) themeColor = const Color(0xFF6A1B9A);

    final bgColor = isActive
        ? (isDark ? themeColor.withValues(alpha: 0.25) : themeColor.withValues(alpha: 0.05))
        : (isDark ? const Color(0xFF26263B) : Colors.white);

    String baseDigitText = '';
    if (presetType == 1) {
      String thresh = preset.maxThreshold != null ? ', Batas: ${preset.maxThreshold}' : '';
      baseDigitText = 'X: ${preset.xDigit} Digit$thresh';
    } else if (presetType == 2) {
      String thresh = preset.maxThreshold != null ? ', Batas: ${preset.maxThreshold}' : '';
      String acak = preset.isRandomDecimalDigits ? ' (Acak)' : '';
      String dec = preset.decimalPlaces != null ? ', Desimal: ${preset.decimalPlaces}$acak' : '';
      baseDigitText = 'X: ${preset.xDigit} Digit, Y: ${preset.yDigit ?? preset.xDigit} Digit$dec$thresh';
    } else if (presetType == 3) {
      final baseVal = preset.baseDigit ?? 10;
      String maxText = baseVal == 9 ? '1 Digit' : 'Max $baseVal';
      baseDigitText = 'Dasar: $maxText, Pangkat: Max ${preset.pangkatLimit ?? 5}, Akar: Max ${preset.akarLimit ?? 20}';
      if (preset.isCampuranLainLain) {
        List<String> cmp = [];
        if (preset.allowCampuranAddSub) cmp.add('+/-');
        if (preset.allowCampuranMulDiv) cmp.add('×/÷');
        String cmpStr = cmp.isNotEmpty ? cmp.join(', ') : 'On';
        baseDigitText += ', Campuran: [$cmpStr]';
      }
    } else {
      final baseVal = preset.baseDigit ?? 100;
      List<String> ops = [];
      if (preset.allowNegative) ops.add('Negatif');
      if (preset.allowDesimal) ops.add('Desimal');
      if (preset.allowPecahan) ops.add('Pecahan');
      if (preset.allowPersentase) ops.add('Persen');
      if (preset.allowAkar) ops.add('Akar');
      if (preset.allowPangkat) ops.add('Pangkat');
      if (preset.allowFaktorial) ops.add('Faktorial');
      if (preset.allowMutlak) ops.add('Mutlak');
      if (preset.allowLogaritma) ops.add('Log');
      if (preset.allowModulo) ops.add('Mod');
      String opsStr = ops.isEmpty ? 'Dasar' : ops.join(', ');
      baseDigitText = 'Awal: ${preset.xDigit} Digit, Max: $baseVal [$opsStr]';
    }

    return GestureDetector(
      onTap: () {
        if (presetType == 1) {
          provider.setActiveVar1Preset(preset.id);
        } else if (presetType == 2) {
          provider.setActiveVar2Preset(preset.id);
        } else if (presetType == 3) {
          provider.setActiveOtherPreset(preset.id);
        } else {
          provider.setActiveMemoryPreset(preset.id);
        }
        provider.setDifficulty('Custom');
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Preset "${preset.name}" aktif (Mode Custom diaktifkan)'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? themeColor : (isDark ? Colors.white12 : Colors.grey.shade300),
            width: isActive ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    preset.name,
                    style: TextStyle(
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF101828),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        baseDigitText,
                        style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 13),
                      ),
                      if (preset.isSwappable) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1976D2).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFF1976D2).withValues(alpha: 0.3)),
                          ),
                          child: const Text(
                            'SW',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1976D2),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              children: [
                if (isActive) Icon(Icons.check_circle, color: themeColor, size: 28),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.grey.shade400, size: 20),
                  onSelected: (val) {
                    if (val == 'edit') {
                      showEditPresetDialog(context, provider, preset, presetType);
                    } else if (val == 'delete') {
                      _showDeleteConfirmation(context, provider, preset, presetType);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomPanel(
    BuildContext context,
    CustomPreset v1,
    CustomPreset v2,
    CustomPreset other,
    CustomPreset memory,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: isDark ? const Color(0xFF80D8FF) : const Color(0xFF0288D1),
                size: 28,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Preset Aktif Saat Ini',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF101828),
                      ),
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                        ),
                        children: [
                          const TextSpan(text: 'Operasi 2 Variabel: '),
                          TextSpan(
                            text: '${v2.name} ',
                            style: const TextStyle(
                              color: Color(0xFF1976D2),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: '(X: ${v2.xDigit} Digit, Y: ${v2.yDigit ?? v2.xDigit} Digit) ',
                          ),
                          if (v2.isSwappable)
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1976D2).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: const Color(0xFF1976D2).withValues(alpha: 0.3)),
                                ),
                                child: const Text(
                                  'SW',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1976D2),
                                  ),
                                ),
                              ),
                            ),
                          const TextSpan(text: '\nOperasi 1 Variabel: '),
                          TextSpan(
                            text: '${v1.name} ',
                            style: const TextStyle(
                              color: Color(0xFF2E7D32),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(text: '(X: ${v1.xDigit} Digit, Limit: ${v1.specialLimit})'),
                          const TextSpan(text: '\nComplex Numbers: '),
                          TextSpan(
                            text: '${other.name} ',
                            style: const TextStyle(
                              color: Color(0xFFE65100),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(text: '(Dasar: ${other.baseDigit != null ? other.baseDigit.toString().length : 1} Digit, Akar: ${other.akarLimit}, Pangkat: ${other.pangkatLimit})'),
                          const TextSpan(text: '\nBerantai (Memory): '),
                          TextSpan(
                            text: '${memory.name} ',
                            style: const TextStyle(
                              color: Color(0xFF6A1B9A),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(text: '(Start: Max ${memory.baseDigit})'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Divider(color: isDark ? Colors.white12 : Colors.grey.shade300),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF26263B) : Colors.grey.shade200,
                    foregroundColor: isDark ? Colors.white70 : Colors.black87,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    context.read<SettingsProvider>().resetPresetsToDefault();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Preset berhasil direset ke default')),
                    );
                  },
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Reset ke Default',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0288D1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Save & Go back
                  },
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Simpan & Gunakan',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

