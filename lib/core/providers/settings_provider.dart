import 'package:flutter/material.dart';
import '../../data/models/app_settings.dart';
import '../../data/local/settings_repository.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsRepository _repository;
  AppSettings _settings = AppSettings();
  bool _isLoaded = false;

  SettingsProvider(this._repository) {
    _loadSettings();
  }

  AppSettings get settings => _settings;
  bool get isLoaded => _isLoaded;

  Future<void> _loadSettings() async {
    _settings = await _repository.loadSettings();
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> updateSettings(AppSettings newSettings) async {
    _settings = newSettings;
    notifyListeners();
    await _repository.saveSettings(_settings);
  }

  void setSounds(bool value) {
    updateSettings(_settings.copyWith(isSoundEnabled: value));
  }

  void setDifficulty(String value) {
    updateSettings(_settings.copyWith(difficulty: value));
  }

  void setQuestionsCount(int count) {
    updateSettings(_settings.copyWith(
      questionCount: count,
      isDurationMode: false,
    ));
  }

  void setLanguage(String lang) {
    updateSettings(_settings.copyWith(language: lang));
  }

  void toggleNegativeNumbers(bool value) {
    updateSettings(_settings.copyWith(isNegativeNumbersEnabled: value));
  }

  void setDisplayTime(bool value) {
    updateSettings(_settings.copyWith(isDisplayTimeEnabled: value));
  }

  void setDurationMinutes(int duration) {
    updateSettings(_settings.copyWith(
      durationMinutes: duration,
      isDurationMode: true,
    ));
  }

  void addVar1Preset(CustomPreset preset) {
    final newList = List<CustomPreset>.from(_settings.var1Presets)..add(preset);
    updateSettings(_settings.copyWith(var1Presets: newList));
  }

  void addVar2Preset(CustomPreset preset) {
    final newList = List<CustomPreset>.from(_settings.var2Presets)..add(preset);
    updateSettings(_settings.copyWith(var2Presets: newList));
  }

  void updateVar1Preset(CustomPreset preset) {
    final newList = List<CustomPreset>.from(_settings.var1Presets);
    final index = newList.indexWhere((p) => p.id == preset.id);
    if (index != -1) {
      newList[index] = preset;
      updateSettings(_settings.copyWith(var1Presets: newList));
    }
  }

  void updateVar2Preset(CustomPreset preset) {
    final newList = List<CustomPreset>.from(_settings.var2Presets);
    final index = newList.indexWhere((p) => p.id == preset.id);
    if (index != -1) {
      newList[index] = preset;
      updateSettings(_settings.copyWith(var2Presets: newList));
    }
  }

  void removeVar1Preset(String id) {
    final newList = List<CustomPreset>.from(_settings.var1Presets)..removeWhere((p) => p.id == id);
    updateSettings(_settings.copyWith(var1Presets: newList));
  }

  void removeVar2Preset(String id) {
    final newList = List<CustomPreset>.from(_settings.var2Presets)..removeWhere((p) => p.id == id);
    updateSettings(_settings.copyWith(var2Presets: newList));
  }

  void setActiveVar1Preset(String id) {
    updateSettings(_settings.copyWith(activeVar1PresetId: id));
  }

  void setActiveVar2Preset(String id) {
    updateSettings(_settings.copyWith(activeVar2PresetId: id));
  }

  void addOtherPreset(CustomPreset preset) {
    final newList = List<CustomPreset>.from(_settings.otherPresets)..add(preset);
    updateSettings(_settings.copyWith(otherPresets: newList));
  }

  void updateOtherPreset(CustomPreset preset) {
    final newList = List<CustomPreset>.from(_settings.otherPresets);
    final index = newList.indexWhere((p) => p.id == preset.id);
    if (index != -1) {
      newList[index] = preset;
      updateSettings(_settings.copyWith(otherPresets: newList));
    }
  }

  void removeOtherPreset(String id) {
    final newList = List<CustomPreset>.from(_settings.otherPresets)..removeWhere((p) => p.id == id);
    updateSettings(_settings.copyWith(otherPresets: newList));
  }

  void setActiveOtherPreset(String id) {
    updateSettings(_settings.copyWith(activeOtherPresetId: id));
  }

  void addMemoryPreset(CustomPreset preset) {
    final newList = List<CustomPreset>.from(_settings.memoryPresets)..add(preset);
    updateSettings(_settings.copyWith(memoryPresets: newList));
  }

  void updateMemoryPreset(CustomPreset preset) {
    final newList = List<CustomPreset>.from(_settings.memoryPresets);
    final index = newList.indexWhere((p) => p.id == preset.id);
    if (index != -1) {
      newList[index] = preset;
      updateSettings(_settings.copyWith(memoryPresets: newList));
    }
  }

  void removeMemoryPreset(String id) {
    final newList = List<CustomPreset>.from(_settings.memoryPresets)..removeWhere((p) => p.id == id);
    updateSettings(_settings.copyWith(memoryPresets: newList));
  }

  void setActiveMemoryPreset(String id) {
    updateSettings(_settings.copyWith(activeMemoryPresetId: id));
  }

  void setThemeName(String name) {
    updateSettings(_settings.copyWith(themeName: name));
  }

  void setKeypadSize(String size) {
    updateSettings(_settings.copyWith(keypadSize: size));
  }

  void setKeypadType(String type) {
    updateSettings(_settings.copyWith(keypadType: type));
  }

  void setAutoConfirm(bool confirm) {
    updateSettings(_settings.copyWith(autoConfirm: confirm));
  }

  void resetPresetsToDefault() {
    final v1Def = [CustomPreset(id: 'v1_def', name: 'Default V1', xDigit: 1)];
    final v2Def = [CustomPreset(id: 'v2_def', name: 'Default V2', xDigit: 1, yDigit: 1)];
    final otherDef = [CustomPreset(id: 'other_def', name: 'Default', xDigit: 1, baseDigit: 10, akarLimit: 20, pangkatLimit: 5)];
    final memDef = [CustomPreset(id: 'mem_def', name: 'Default', xDigit: 1, baseDigit: 100, allowAkar: false, allowPangkat: false, allowPecahan: false, allowDesimal: false)];

    updateSettings(_settings.copyWith(
      var1Presets: v1Def,
      var2Presets: v2Def,
      otherPresets: otherDef,
      memoryPresets: memDef,
      activeVar1PresetId: v1Def.first.id,
      activeVar2PresetId: v2Def.first.id,
      activeOtherPresetId: otherDef.first.id,
      activeMemoryPresetId: memDef.first.id,
    ));
  }

  void updateNotification(NotificationSchedule schedule) {
    final list = List<NotificationSchedule>.from(_settings.notifications);
    final index = list.indexWhere((n) => n.dayOfWeek == schedule.dayOfWeek);
    if (index != -1) {
      list[index] = schedule;
      updateSettings(_settings.copyWith(notifications: list));
    }
  }
}
