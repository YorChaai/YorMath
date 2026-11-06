import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';

class SettingsRepository {
  static const _keySounds = 'sounds';
  static const _keyDifficulty = 'difficulty';
  static const _keyQuestions = 'questions';
  static const _keyLanguage = 'language';
  static const _keyDisplayTime = 'display_time';
  static const _keyVar1Presets = 'var1_presets';
  static const _keyVar2Presets = 'var2_presets';
  static const _keyActiveVar1Preset = 'active_var1_preset';
  static const _keyActiveVar2Preset = 'active_var2_preset';
  static const _keyDuration = 'duration_minutes';
  static const _keyDurationMode = 'is_duration_mode';
  static const _keyNegativeNumbers = 'negative_numbers';
  static const _keyThemeName = 'theme_name';
  static const _keyKeypadSize = 'keypad_size';
  static const _keyKeypadType = 'keypad_type';
  static const _keyAutoConfirm = 'auto_confirm';
  static const _keyNotifications = 'notifications_schedule';
  static const _keyCustomMixed = 'custom_mixed_ops';
  static const _keyActiveNumberTypes = 'active_number_types';
  static const _keyOtherPresets = 'other_presets_v2';
  static const _keyActiveOtherPreset = 'active_other_preset_v2';
  static const _keyMemoryPresets = 'memory_presets';
  static const _keyActiveMemoryPreset = 'active_memory_preset';

  Future<AppSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load presets
    final var1PresetsJson = prefs.getStringList(_keyVar1Presets) ?? [];
    final var2PresetsJson = prefs.getStringList(_keyVar2Presets) ?? [];
    final otherPresetsJson = prefs.getStringList(_keyOtherPresets) ?? [];
    final memoryPresetsJson = prefs.getStringList(_keyMemoryPresets) ?? [];
    
    final var1Presets = var1PresetsJson.map((e) => CustomPreset.fromJson(jsonDecode(e))).toList();
    final var2Presets = var2PresetsJson.map((e) => CustomPreset.fromJson(jsonDecode(e))).toList();
    final otherPresets = otherPresetsJson.map((e) => CustomPreset.fromJson(jsonDecode(e))).toList();
    final memoryPresets = memoryPresetsJson.map((e) => CustomPreset.fromJson(jsonDecode(e))).toList();
    
    // Load notifications
    final notificationsJson = prefs.getStringList(_keyNotifications) ?? [];
    List<NotificationSchedule> notifications = notificationsJson.map((e) => NotificationSchedule.fromJson(jsonDecode(e))).toList();
    
    if (notifications.isEmpty) {
      for (int i = 1; i <= 7; i++) {
        notifications.add(NotificationSchedule(dayOfWeek: i, hour: 12, minute: 0, isEnabled: false));
      }
    }
    
    // Default presets if empty
    if (var1Presets.isEmpty) {
      // For 1-variable operations, we only need X
      var1Presets.add(CustomPreset(id: 'v1_def', name: 'Default V1', xDigit: 1));
    }
    if (var2Presets.isEmpty) {
      // For 2-variable operations, we need X and Y
      var2Presets.add(CustomPreset(id: 'v2_def', name: 'Default V2', xDigit: 1, yDigit: 1));
    }
    if (otherPresets.isEmpty) {
      // For Lain-Lain (Akar, Pangkat), use baseDigit, akarLimit, pangkatLimit
      otherPresets.add(CustomPreset(id: 'other_def', name: 'Default', xDigit: 1, baseDigit: 10, akarLimit: 20, pangkatLimit: 5));
    }
    if (memoryPresets.isEmpty) {
      // For Memory, use baseDigit, and toggles
      memoryPresets.add(CustomPreset(id: 'mem_def', name: 'Default', xDigit: 1, baseDigit: 100, allowAkar: false, allowPangkat: false, allowPecahan: false, allowDesimal: false));
    }

    return AppSettings(
      isSoundEnabled: prefs.getBool(_keySounds) ?? true,
      difficulty: prefs.getString(_keyDifficulty) ?? 'Easy',
      questionCount: prefs.getInt(_keyQuestions) ?? 10,
      language: prefs.getString(_keyLanguage) ?? 'English',
      isDisplayTimeEnabled: prefs.getBool(_keyDisplayTime) ?? true,
      durationMinutes: prefs.getInt(_keyDuration) ?? 5,
      isDurationMode: prefs.getBool(_keyDurationMode) ?? false,
      isNegativeNumbersEnabled: prefs.getBool(_keyNegativeNumbers) ?? false,
      var1Presets: var1Presets,
      var2Presets: var2Presets,
      otherPresets: otherPresets,
      memoryPresets: memoryPresets,
      activeVar1PresetId: prefs.getString(_keyActiveVar1Preset) ?? var1Presets.first.id,
      activeVar2PresetId: prefs.getString(_keyActiveVar2Preset) ?? var2Presets.first.id,
      activeOtherPresetId: prefs.getString(_keyActiveOtherPreset) ?? otherPresets.first.id,
      activeMemoryPresetId: prefs.getString(_keyActiveMemoryPreset) ?? memoryPresets.first.id,
      themeName: prefs.getString(_keyThemeName) ?? 'Default',
      keypadSize: prefs.getString(_keyKeypadSize) ?? 'Normal',
      keypadType: prefs.getString(_keyKeypadType) ?? 'Phone',
      autoConfirm: prefs.getBool(_keyAutoConfirm) ?? false,
      notifications: notifications,
      customMixedOperations: prefs.getStringList(_keyCustomMixed) ?? const [
        "Penjumlahan",
        "Pengurangan",
        "Perkalian",
        "Pembagian"
      ],
      activeNumberTypes: prefs.getStringList(_keyActiveNumberTypes) ?? const [
        "Bulat"
      ],
    );
  }

  Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySounds, settings.isSoundEnabled);
    await prefs.setString(_keyDifficulty, settings.difficulty);
    await prefs.setInt(_keyQuestions, settings.questionCount);
    await prefs.setString(_keyLanguage, settings.language);
    await prefs.setBool(_keyDisplayTime, settings.isDisplayTimeEnabled);
    await prefs.setInt(_keyDuration, settings.durationMinutes);
    await prefs.setBool(_keyDurationMode, settings.isDurationMode);
    await prefs.setBool(_keyNegativeNumbers, settings.isNegativeNumbersEnabled);
    
    // Save presets
    final var1List = settings.var1Presets.map((e) => jsonEncode(e.toJson())).toList();
    final var2List = settings.var2Presets.map((e) => jsonEncode(e.toJson())).toList();
    final otherList = settings.otherPresets.map((e) => jsonEncode(e.toJson())).toList();
    final memoryList = settings.memoryPresets.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_keyVar1Presets, var1List);
    await prefs.setStringList(_keyVar2Presets, var2List);
    await prefs.setStringList(_keyOtherPresets, otherList);
    await prefs.setStringList(_keyMemoryPresets, memoryList);
    
    if (settings.activeVar1PresetId != null) {
      await prefs.setString(_keyActiveVar1Preset, settings.activeVar1PresetId!);
    }
    if (settings.activeVar2PresetId != null) {
      await prefs.setString(_keyActiveVar2Preset, settings.activeVar2PresetId!);
    }
    if (settings.activeOtherPresetId != null) {
      await prefs.setString(_keyActiveOtherPreset, settings.activeOtherPresetId!);
    }
    if (settings.activeMemoryPresetId != null) {
      await prefs.setString(_keyActiveMemoryPreset, settings.activeMemoryPresetId!);
    }
    
    await prefs.setString(_keyThemeName, settings.themeName);
    await prefs.setString(_keyKeypadSize, settings.keypadSize);
    await prefs.setString(_keyKeypadType, settings.keypadType);
    await prefs.setBool(_keyAutoConfirm, settings.autoConfirm);
    await prefs.setStringList(_keyNotifications, settings.notifications.map((e) => jsonEncode(e.toJson())).toList());
    await prefs.setStringList(_keyCustomMixed, settings.customMixedOperations);
    await prefs.setStringList(_keyActiveNumberTypes, settings.activeNumberTypes);
  }
}
