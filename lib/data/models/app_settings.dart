class CustomPreset {
  final String id;
  final String name;
  final int xDigit;
  final int? yDigit; // null if for 1-variable operation
  final int? baseDigit;
  final int? akarLimit;
  final int? pangkatLimit;
  final int? maxThreshold;
  final int? decimalPlaces;
  final int specialLimit; // deprecated, use akarLimit/pangkatLimit instead
  final bool isSwappable;
  final bool allowAkar;
  final bool allowPangkat;
  final bool allowPecahan;
  final bool allowDesimal;
  final bool allowPersentase;
  final bool allowFaktorial;
  final bool allowMutlak;
  final bool allowLogaritma;
  final bool allowModulo;
  final bool allowNegative;
  final bool isCampuranLainLain;
  final bool allowCampuranAddSub;
  final bool allowCampuranMulDiv;

  CustomPreset({
    required this.id,
    required this.name,
    required this.xDigit,
    this.yDigit,
    this.baseDigit,
    this.akarLimit,
    this.pangkatLimit,
    this.maxThreshold,
    this.decimalPlaces,
    this.specialLimit = 5,
    this.isSwappable = false,
    this.allowAkar = false,
    this.allowPangkat = false,
    this.allowPecahan = false,
    this.allowDesimal = false,
    this.allowPersentase = false,
    this.allowFaktorial = false,
    this.allowMutlak = false,
    this.allowLogaritma = false,
    this.allowModulo = false,
    this.allowNegative = false,
    this.isCampuranLainLain = false,
    this.allowCampuranAddSub = true,
    this.allowCampuranMulDiv = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'xDigit': xDigit,
    'yDigit': yDigit,
    'baseDigit': baseDigit,
    'akarLimit': akarLimit,
    'pangkatLimit': pangkatLimit,
    'maxThreshold': maxThreshold,
    'decimalPlaces': decimalPlaces,
    'specialLimit': specialLimit,
    'isSwappable': isSwappable,
    'allowAkar': allowAkar,
    'allowPangkat': allowPangkat,
    'allowPecahan': allowPecahan,
    'allowDesimal': allowDesimal,
    'allowPersentase': allowPersentase,
    'allowFaktorial': allowFaktorial,
    'allowMutlak': allowMutlak,
    'allowLogaritma': allowLogaritma,
    'allowModulo': allowModulo,
    'allowNegative': allowNegative,
    'isCampuranLainLain': isCampuranLainLain,
    'allowCampuranAddSub': allowCampuranAddSub,
    'allowCampuranMulDiv': allowCampuranMulDiv,
  };

  factory CustomPreset.fromJson(Map<String, dynamic> json) {
    int parseDigit(dynamic digit, dynamic max) {
      if (digit != null) return digit as int;
      if (max != null) {
        int m = max as int;
        return m.toString().length;
      }
      return 1;
    }

    return CustomPreset(
      id: json['id'],
      name: json['name'],
      xDigit: parseDigit(json['xDigit'], json['xMax']),
      yDigit: json['yDigit'] ?? (json['yMax'] != null ? parseDigit(null, json['yMax']) : null),
      baseDigit: json['baseDigit'],
      akarLimit: json['akarLimit'],
      pangkatLimit: json['pangkatLimit'],
      maxThreshold: json['maxThreshold'],
      decimalPlaces: json['decimalPlaces'],
      specialLimit: json['specialLimit'] ?? 5,
      isSwappable: json['isSwappable'] ?? false,
      allowAkar: json['allowAkar'] ?? false,
      allowPangkat: json['allowPangkat'] ?? false,
      allowPecahan: json['allowPecahan'] ?? false,
      allowDesimal: json['allowDesimal'] ?? false,
      allowPersentase: json['allowPersentase'] ?? false,
      allowFaktorial: json['allowFaktorial'] ?? false,
      allowMutlak: json['allowMutlak'] ?? false,
      allowLogaritma: json['allowLogaritma'] ?? false,
      allowModulo: json['allowModulo'] ?? false,
      allowNegative: json['allowNegative'] ?? false,
      isCampuranLainLain: json['isCampuranLainLain'] ?? false,
      allowCampuranAddSub: json['allowCampuranAddSub'] ?? true,
      allowCampuranMulDiv: json['allowCampuranMulDiv'] ?? true,
    );
  }
}

class NotificationSchedule {
  final int dayOfWeek; // 1 = Monday, 7 = Sunday
  final int hour;
  final int minute;
  final bool isEnabled;

  NotificationSchedule({
    required this.dayOfWeek,
    required this.hour,
    required this.minute,
    required this.isEnabled,
  });

  Map<String, dynamic> toJson() => {
    'dayOfWeek': dayOfWeek,
    'hour': hour,
    'minute': minute,
    'isEnabled': isEnabled,
  };

  factory NotificationSchedule.fromJson(Map<String, dynamic> json) => NotificationSchedule(
    dayOfWeek: json['dayOfWeek'],
    hour: json['hour'],
    minute: json['minute'],
    isEnabled: json['isEnabled'],
  );
}

class AppSettings {
  final bool isSoundEnabled;
  final String difficulty;
  final int questionCount;
  final String language;
  final bool isDisplayTimeEnabled;
  final int durationMinutes;
  final bool isDurationMode;
  final bool isNegativeNumbersEnabled;
  final List<CustomPreset> var1Presets;
  final List<CustomPreset> var2Presets;
  final List<CustomPreset> otherPresets;
  final List<CustomPreset> memoryPresets;
  final String? activeVar1PresetId;
  final String? activeVar2PresetId;
  final String? activeOtherPresetId;
  final String? activeMemoryPresetId;
  
  // Theme Settings
  final String themeName; // Default, Dark, Blue, Purple
  
  // Keypad Settings
  final String keypadSize; // Normal, Large
  final String keypadType; // Phone, Calculator
  final bool autoConfirm;
  
  // Notification Settings
  final List<NotificationSchedule> notifications;

  // Custom Mixed Operations
  final List<String> customMixedOperations;

  // Active Number Types for Basic Operations
  final List<String> activeNumberTypes;

  static final CustomPreset defaultVar1 = CustomPreset(id: 'v1_def', name: 'Default V1', xDigit: 1);
  static final CustomPreset defaultVar2 = CustomPreset(id: 'v2_def', name: 'Default V2', xDigit: 1, yDigit: 1);
  static final CustomPreset defaultOther = CustomPreset(id: 'other_def', name: 'Default', xDigit: 1, baseDigit: 10, akarLimit: 20, pangkatLimit: 5);
  static final CustomPreset defaultMemory = CustomPreset(id: 'mem_def', name: 'Default', xDigit: 1, baseDigit: 100, allowAkar: false, allowPangkat: false, allowPecahan: false, allowDesimal: false);

  AppSettings({
    this.isSoundEnabled = true,
    this.difficulty = 'Easy',
    this.questionCount = 10,
    this.language = 'English',
    this.isDisplayTimeEnabled = true,
    this.durationMinutes = 5,
    this.isDurationMode = false,
    this.isNegativeNumbersEnabled = false,
    List<CustomPreset>? var1Presets,
    List<CustomPreset>? var2Presets,
    List<CustomPreset>? otherPresets,
    List<CustomPreset>? memoryPresets,
    String? activeVar1PresetId,
    String? activeVar2PresetId,
    String? activeOtherPresetId,
    String? activeMemoryPresetId,
    this.themeName = 'Default',
    this.keypadSize = 'Normal',
    this.keypadType = 'Phone',
    this.autoConfirm = false,
    this.notifications = const [],
    this.customMixedOperations = const [
      "Penjumlahan",
      "Pengurangan",
      "Perkalian",
      "Pembagian"
    ],
    this.activeNumberTypes = const [
      "Bulat"
    ],
  })  : var1Presets = var1Presets ?? [defaultVar1],
        var2Presets = var2Presets ?? [defaultVar2],
        otherPresets = otherPresets ?? [defaultOther],
        memoryPresets = memoryPresets ?? [defaultMemory],
        activeVar1PresetId = activeVar1PresetId ?? (var1Presets != null && var1Presets.isNotEmpty ? var1Presets.first.id : defaultVar1.id),
        activeVar2PresetId = activeVar2PresetId ?? (var2Presets != null && var2Presets.isNotEmpty ? var2Presets.first.id : defaultVar2.id),
        activeOtherPresetId = activeOtherPresetId ?? (otherPresets != null && otherPresets.isNotEmpty ? otherPresets.first.id : defaultOther.id),
        activeMemoryPresetId = activeMemoryPresetId ?? (memoryPresets != null && memoryPresets.isNotEmpty ? memoryPresets.first.id : defaultMemory.id);

  CustomPreset get activeVar1Preset => var1Presets.firstWhere(
        (p) => p.id == activeVar1PresetId,
        orElse: () => var1Presets.isNotEmpty ? var1Presets.first : defaultVar1,
      );
  CustomPreset get activeVar2Preset => var2Presets.firstWhere(
        (p) => p.id == activeVar2PresetId,
        orElse: () => var2Presets.isNotEmpty ? var2Presets.first : defaultVar2,
      );
  CustomPreset get activeOtherPreset => otherPresets.firstWhere(
        (p) => p.id == activeOtherPresetId,
        orElse: () => otherPresets.isNotEmpty ? otherPresets.first : defaultOther,
      );
  CustomPreset get activeMemoryPreset => memoryPresets.firstWhere(
        (p) => p.id == activeMemoryPresetId,
        orElse: () => memoryPresets.isNotEmpty ? memoryPresets.first : defaultMemory,
      );

  AppSettings copyWith({
    bool? isSoundEnabled,
    String? difficulty,
    int? questionCount,
    String? language,
    bool? isDisplayTimeEnabled,
    int? durationMinutes,
    bool? isDurationMode,
    bool? isNegativeNumbersEnabled,
    List<CustomPreset>? var1Presets,
    List<CustomPreset>? var2Presets,
    List<CustomPreset>? otherPresets,
    List<CustomPreset>? memoryPresets,
    String? activeVar1PresetId,
    String? activeVar2PresetId,
    String? activeOtherPresetId,
    String? activeMemoryPresetId,
    String? themeName,
    String? keypadSize,
    String? keypadType,
    bool? autoConfirm,
    List<NotificationSchedule>? notifications,
    List<String>? customMixedOperations,
    List<String>? activeNumberTypes,
  }) {
    return AppSettings(
      isSoundEnabled: isSoundEnabled ?? this.isSoundEnabled,
      difficulty: difficulty ?? this.difficulty,
      questionCount: questionCount ?? this.questionCount,
      language: language ?? this.language,
      isDisplayTimeEnabled: isDisplayTimeEnabled ?? this.isDisplayTimeEnabled,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      isDurationMode: isDurationMode ?? this.isDurationMode,
      isNegativeNumbersEnabled: isNegativeNumbersEnabled ?? this.isNegativeNumbersEnabled,
      var1Presets: var1Presets ?? this.var1Presets,
      var2Presets: var2Presets ?? this.var2Presets,
      otherPresets: otherPresets ?? this.otherPresets,
      memoryPresets: memoryPresets ?? this.memoryPresets,
      activeVar1PresetId: activeVar1PresetId ?? this.activeVar1PresetId,
      activeVar2PresetId: activeVar2PresetId ?? this.activeVar2PresetId,
      activeOtherPresetId: activeOtherPresetId ?? this.activeOtherPresetId,
      activeMemoryPresetId: activeMemoryPresetId ?? this.activeMemoryPresetId,
      themeName: themeName ?? this.themeName,
      keypadSize: keypadSize ?? this.keypadSize,
      keypadType: keypadType ?? this.keypadType,
      autoConfirm: autoConfirm ?? this.autoConfirm,
      notifications: notifications ?? this.notifications,
      customMixedOperations: customMixedOperations ?? this.customMixedOperations,
      activeNumberTypes: activeNumberTypes ?? this.activeNumberTypes,
    );
  }
}
