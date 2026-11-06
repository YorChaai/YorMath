import 'package:flutter_test/flutter_test.dart';
import 'package:mathall/data/models/app_settings.dart';

void main() {
  group('AppSettings Custom Preset Fallbacks', () {
    test('default AppSettings initializes non-empty presets and valid active IDs', () {
      final settings = AppSettings();

      expect(settings.var1Presets.isNotEmpty, isTrue);
      expect(settings.var2Presets.isNotEmpty, isTrue);
      expect(settings.otherPresets.isNotEmpty, isTrue);
      expect(settings.memoryPresets.isNotEmpty, isTrue);

      expect(settings.activeVar1Preset.name, 'Default V1');
      expect(settings.activeVar2Preset.name, 'Default V2');
      expect(settings.activeOtherPreset.name, 'Default');
      expect(settings.activeMemoryPreset.name, 'Default');
    });

    test('AppSettings with empty lists gracefully falls back without throwing Bad state: No element', () {
      final settings = AppSettings(
        var1Presets: [],
        var2Presets: [],
        otherPresets: [],
        memoryPresets: [],
        activeVar1PresetId: 'non_existent_id',
        activeVar2PresetId: 'non_existent_id',
        activeOtherPresetId: 'non_existent_id',
        activeMemoryPresetId: 'non_existent_id',
      );

      expect(() => settings.activeVar1Preset, returnsNormally);
      expect(() => settings.activeVar2Preset, returnsNormally);
      expect(() => settings.activeOtherPreset, returnsNormally);
      expect(() => settings.activeMemoryPreset, returnsNormally);

      expect(settings.activeVar1Preset.name, 'Default V1');
      expect(settings.activeVar2Preset.name, 'Default V2');
      expect(settings.activeOtherPreset.name, 'Default');
      expect(settings.activeMemoryPreset.name, 'Default');
    });
  });
}
