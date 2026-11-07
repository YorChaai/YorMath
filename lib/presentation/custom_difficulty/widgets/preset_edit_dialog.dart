import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mathall/data/models/app_settings.dart';
import 'package:mathall/core/providers/settings_provider.dart';
import 'package:mathall/core/localization/app_localizations.dart';
import 'live_question_preview.dart';

  Future<void> showEditPresetDialog(BuildContext context, SettingsProvider provider, CustomPreset preset, int presetType) {
    final lang = provider.settings.language;
    String name = preset.name;
    int xDigit = preset.xDigit;
    int yDigit = preset.yDigit ?? 1;
    int baseDigit = 10;
    if ((presetType == 3 || presetType == 4) && preset.baseDigit != null) {
      baseDigit = preset.baseDigit!;
      if (![9, 10, 20, 30, 40, 50, 100, 200, 500, 1000].contains(baseDigit)) {
        baseDigit = presetType == 4 ? 100 : 10;
      }
    }
    int akarLimit = preset.akarLimit ?? 20;
    int pangkatLimit = preset.pangkatLimit ?? 5;
    bool isSwappable = preset.isSwappable;
    bool allowAkar = preset.allowAkar;
    bool allowPangkat = preset.allowPangkat;
    bool allowPecahan = preset.allowPecahan;
    bool allowDesimal = preset.allowDesimal;
    bool allowPersentase = preset.allowPersentase;
    bool allowFaktorial = preset.allowFaktorial;
    bool allowMutlak = preset.allowMutlak;
    bool allowLogaritma = preset.allowLogaritma;
    bool allowModulo = preset.allowModulo;
    bool allowNegative = preset.allowNegative;
    bool isCampuranLainLain = preset.isCampuranLainLain;
    bool allowCampuranAddSub = preset.allowCampuranAddSub;
    bool allowCampuranMulDiv = preset.allowCampuranMulDiv;
    int? decimalPlaces = preset.decimalPlaces ?? 1;
    bool isRandomDecimalDigits = preset.isRandomDecimalDigits;
    int? maxThreshold = preset.maxThreshold ?? 505;

    Widget buildStyledSwitch({required String title, required String subtitle, required IconData iconData, required Color iconColor, required bool value, required Function(bool) onChanged}) {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        elevation: 1,
        child: SwitchListTile(
          secondary: Icon(iconData, color: iconColor),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          value: value,
          onChanged: onChanged,
        ),
      );
    }

    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Edit Preset', style: TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Nama Preset',
                        border: OutlineInputBorder(),
                      ),
                      controller: TextEditingController(text: name),
                      onChanged: (val) => name = val,
                    ),
                    const SizedBox(height: 12),
                    if (presetType == 1) ...[
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
                              'Batas Maksimum Angka:',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 100,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                border: OutlineInputBorder(),
                              ),
                              controller: TextEditingController(text: maxThreshold?.toString() ?? '505'),
                              onChanged: (val) {
                                maxThreshold = int.tryParse(val);
                              },
                            ),
                          ),
                        ],
                      ),
                    ] else if (presetType == 2) ...[
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
                          Text(
                            AppLocalizations.get(lang, 'switch_xy'),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Switch(
                            value: isSwappable,
                            onChanged: (val) => setState(() => isSwappable = val),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              AppLocalizations.get(lang, 'decimal_places_label'),
                              style: const TextStyle(fontWeight: FontWeight.w600),
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
                            child: Text(
                              AppLocalizations.get(lang, 'random_decimal_digits'),
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          Switch(
                            value: isRandomDecimalDigits,
                            onChanged: (val) => setState(() => isRandomDecimalDigits = val),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'Batas Maksimum Angka:',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 100,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                border: OutlineInputBorder(),
                              ),
                              controller: TextEditingController(text: maxThreshold?.toString() ?? '505'),
                              onChanged: (val) {
                                maxThreshold = int.tryParse(val);
                              },
                            ),
                          ),
                        ],
                      ),
                    ] else if (presetType == 3) ...[
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
                    ] else if (presetType == 4) ...[
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'Batas Maksimum Angka:',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 100,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                border: OutlineInputBorder(),
                              ),
                              controller: TextEditingController(text: maxThreshold?.toString() ?? '505'),
                              onChanged: (val) {
                                maxThreshold = int.tryParse(val);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('Tipe Operasi:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                      const SizedBox(height: 8),
                      buildStyledSwitch(
                        title: 'Bilangan Negatif',
                        subtitle: 'Contoh: -5, - (-2)',
                        iconData: Icons.remove_circle_outline,
                        iconColor: Colors.red,
                        value: allowNegative,
                        onChanged: (val) => setState(() => allowNegative = val),
                      ),
                      buildStyledSwitch(
                        title: 'Desimal',
                        subtitle: 'Contoh: × 1.5, × 0.5',
                        iconData: Icons.money,
                        iconColor: Colors.green,
                        value: allowDesimal,
                        onChanged: (val) => setState(() => allowDesimal = val),
                      ),
                      buildStyledSwitch(
                        title: 'Pecahan',
                        subtitle: 'Contoh: ÷ 1/2',
                        iconData: Icons.pie_chart,
                        iconColor: Colors.teal,
                        value: allowPecahan,
                        onChanged: (val) => setState(() => allowPecahan = val),
                      ),
                      buildStyledSwitch(
                        title: 'Persentase',
                        subtitle: 'Contoh: 10%, 50%',
                        iconData: Icons.local_offer,
                        iconColor: Colors.orangeAccent,
                        value: allowPersentase,
                        onChanged: (val) => setState(() => allowPersentase = val),
                      ),
                      buildStyledSwitch(
                        title: 'Akar',
                        subtitle: 'Contoh: √16, √25',
                        iconData: Icons.square_foot,
                        iconColor: Colors.orange,
                        value: allowAkar,
                        onChanged: (val) => setState(() => allowAkar = val),
                      ),
                      buildStyledSwitch(
                        title: 'Pangkat',
                        subtitle: 'Contoh: 2², 3³',
                        iconData: Icons.arrow_upward,
                        iconColor: Colors.purple,
                        value: allowPangkat,
                        onChanged: (val) => setState(() => allowPangkat = val),
                      ),
                      buildStyledSwitch(
                        title: 'Faktorial',
                        subtitle: 'Contoh: 5!',
                        iconData: Icons.priority_high,
                        iconColor: Colors.redAccent,
                        value: allowFaktorial,
                        onChanged: (val) => setState(() => allowFaktorial = val),
                      ),
                      buildStyledSwitch(
                        title: 'Nilai Mutlak',
                        subtitle: 'Contoh: |-5|',
                        iconData: Icons.code,
                        iconColor: Colors.blueGrey,
                        value: allowMutlak,
                        onChanged: (val) => setState(() => allowMutlak = val),
                      ),
                      buildStyledSwitch(
                        title: 'Logaritma',
                        subtitle: 'Contoh: log₂',
                        iconData: Icons.functions,
                        iconColor: Colors.indigo,
                        value: allowLogaritma,
                        onChanged: (val) => setState(() => allowLogaritma = val),
                      ),
                      buildStyledSwitch(
                        title: 'Modulo',
                        subtitle: 'Contoh: mod 3',
                        iconData: Icons.calculate,
                        iconColor: Colors.cyan,
                        value: allowModulo,
                        onChanged: (val) => setState(() => allowModulo = val),
                      ),
                    ],
                    LiveQuestionPreview(
                      presetType: presetType,
                      xDigit: xDigit,
                      yDigit: yDigit,
                      baseDigit: baseDigit,
                      akarLimit: akarLimit,
                      pangkatLimit: pangkatLimit,
                      decimalPlaces: decimalPlaces,
                      isRandomDecimalDigits: isRandomDecimalDigits,
                      maxThreshold: maxThreshold,
                      lang: lang,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.get(lang, 'cancel'), style: const TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    final presetName = name.trim().isEmpty ? 'Preset ${Random().nextInt(1000)}' : name.trim();
                    final updatedPreset = CustomPreset(
                      id: preset.id,
                      name: presetName,
                      xDigit: (presetType == 1 || presetType == 2 || presetType == 4) ? xDigit : 1,
                      yDigit: presetType == 2 ? yDigit : null,
                      baseDigit: (presetType == 3 || presetType == 4) ? baseDigit : null,
                      akarLimit: presetType == 3 ? akarLimit : null,
                      pangkatLimit: presetType == 3 ? pangkatLimit : null,
                      isSwappable: presetType == 2 ? isSwappable : false,
                      allowAkar: presetType == 4 ? allowAkar : false,
                      allowPangkat: presetType == 4 ? allowPangkat : false,
                      allowPecahan: presetType == 4 ? allowPecahan : false,
                      allowDesimal: presetType == 4 ? allowDesimal : false,
                      allowPersentase: presetType == 4 ? allowPersentase : false,
                      allowFaktorial: presetType == 4 ? allowFaktorial : false,
                      allowMutlak: presetType == 4 ? allowMutlak : false,
                      allowLogaritma: presetType == 4 ? allowLogaritma : false,
                      allowModulo: presetType == 4 ? allowModulo : false,
                      allowNegative: presetType == 4 ? allowNegative : false,
                      isCampuranLainLain: presetType == 3 ? isCampuranLainLain : false,
                      allowCampuranAddSub: presetType == 3 ? allowCampuranAddSub : true,
                      allowCampuranMulDiv: presetType == 3 ? allowCampuranMulDiv : true,
                      decimalPlaces: presetType == 2 ? decimalPlaces : null,
                      isRandomDecimalDigits: presetType == 2 ? isRandomDecimalDigits : false,
                      maxThreshold: (presetType == 1 || presetType == 2 || presetType == 4) ? maxThreshold : null,
                    );
                    
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(lang == 'English' ? 'Confirmation' : 'Konfirmasi'),
                        content: Text(lang == 'English' ? 'Are you sure you want to save changes?' : 'Apakah Anda yakin ingin menyimpan perubahan?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(AppLocalizations.get(lang, 'cancel'), style: const TextStyle(color: Colors.grey)),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1976D2)),
                            onPressed: () {
                              if (presetType == 1) {
                                provider.updateVar1Preset(updatedPreset);
                              } else if (presetType == 2) {
                                provider.updateVar2Preset(updatedPreset);
                              } else if (presetType == 3) {
                                provider.updateOtherPreset(updatedPreset);
                              } else if (presetType == 4) {
                                provider.updateMemoryPreset(updatedPreset);
                              }
                              Navigator.pop(context); // close confirmation
                              Navigator.pop(context); // close edit dialog
                            },
                            child: Text(AppLocalizations.get(lang, 'save'), style: const TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text(AppLocalizations.get(lang, 'save')),
                ),
              ],
            );
          }
        );
      },
    );
  }
